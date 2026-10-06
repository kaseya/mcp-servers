/**
 * Conformance test for the relay, network-free: the official SDK `Client`, speaking stdio to the built
 * relay, which speaks Streamable HTTP to an official SDK server. The server is built with
 * `createMcpHandler(factory, { legacy: 'stateless' })`, as the Autotask server is, and answers a request
 * without the three credential headers with a 401 `{ code, message }`, as the Autotask server's
 * admission does.
 *
 * Every endpoint is a host under `autotask.net`. The relay starts with `test/fetchPreload.mjs`, which
 * sends each test host to its fake server on loopback, so the relay's endpoint checks run on the same
 * kind of value a customer configures. Every case also asserts that no credential value appears on the
 * relay's stderr or in an error the client receives.
 *
 * Each case runs against the bundle `npm run build` wrote, or against the path given as the first
 * argument, which is how a deliberately broken build is checked to fail.
 */
import http from 'node:http';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { z } from 'zod';
import { McpServer, createMcpHandler } from '@modelcontextprotocol/server';
import { Client } from '@modelcontextprotocol/client';
import { StdioClientTransport } from '@modelcontextprotocol/client/stdio';

const RELAY = process.argv[2] ?? fileURLToPath(new URL('../dist/relay.cjs', import.meta.url));
const PRELOAD = pathToFileURL(fileURLToPath(new URL('./fetchPreload.mjs', import.meta.url))).href;
const CREDENTIALS = {
  username: 'fake@example.invalid',
  secret: 'fake-secret-value',
  code: 'FAKECODE123',
};

/** The test hosts, each sent by the preload to one fake server. */
const HOST = {
  mcp: 'mcptest.autotask.net',
  redirect: 'mcpredirect.autotask.net',
  cut: 'mcpcut.autotask.net',
  outside: 'evil.example.com',
};
const ENDPOINT = `https://${HOST.mcp}/mcp`;

/** @type {{ httpMethod: string | undefined, method: string | undefined, headers: http.IncomingHttpHeaders }[]} */
const seen = []; // every request the MCP server received
let slowCallAborted = false;

const handler = createMcpHandler(
  async () => {
    const server = new McpServer(
      { name: 'fake-autotask', version: '0' },
      { capabilities: { tools: {} } },
    );
    server.registerTool(
      'get_ticket',
      {
        title: 'Get ticket',
        description: 'Echo',
        inputSchema: z.object({ ticketNumber: z.string() }),
      },
      async ({ ticketNumber }) => ({ content: [{ type: 'text', text: `ticket ${ticketNumber}` }] }),
    );
    server.registerTool(
      'slow_query',
      { title: 'Slow', description: 'Waits', inputSchema: z.object({}) },
      async (_args, extra) =>
        new Promise((resolve) => {
          const signal = extra.mcpReq.signal;
          const timer = setTimeout(
            () => resolve({ content: [{ type: 'text', text: 'done' }] }),
            5000,
          );
          signal.addEventListener('abort', () => {
            slowCallAborted = true;
            clearTimeout(timer);
            resolve({ content: [{ type: 'text', text: 'aborted' }] });
          });
        }),
    );
    return server;
  },
  { legacy: 'stateless' },
);

/**
 * @param {http.IncomingMessage} req
 * @param {Buffer} body
 * @param {number} port
 * @param {AbortSignal} signal
 */
function toWebRequest(req, body, port, signal) {
  const method = req.method ?? 'GET';
  return new Request(`http://127.0.0.1:${port}${req.url}`, {
    signal,
    method,
    headers: Object.entries(req.headers).flatMap(([name, value]) =>
      value === undefined
        ? []
        : Array.isArray(value)
          ? value.map((oneValue) => /** @type {[string, string]} */ ([name, oneValue]))
          : [/** @type {[string, string]} */ ([name, value])],
    ),
    body: ['GET', 'HEAD'].includes(method) ? undefined : body,
  });
}

/**
 * @param {http.ServerResponse} res
 * @param {Response} response
 */
async function writeWebResponse(res, response) {
  res.writeHead(response.status, Object.fromEntries(response.headers));
  if (response.body) for await (const chunk of response.body) res.write(chunk);
  res.end();
}

/**
 * Starts a server on a loopback port and resolves with that port.
 *
 * @param {http.RequestListener} listener
 * @returns {Promise<{ server: http.Server, port: number }>}
 */
function listen(listener) {
  return new Promise((resolve) => {
    const server = http.createServer(listener);
    server.listen(0, '127.0.0.1', () => {
      const address = server.address();
      resolve({ server, port: typeof address === 'object' && address !== null ? address.port : 0 });
    });
  });
}

const mcp = await listen(async (req, res) => {
  /** @type {Buffer[]} */
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const body = Buffer.concat(chunks);
  let method;
  try {
    method = JSON.parse(body.toString()).method;
  } catch {
    // A GET or DELETE carries no body, so it records no method.
  }
  seen.push({ httpMethod: req.method, method, headers: req.headers });
  // The Autotask admission rule, in miniature: all three credential headers or a 401 with { code, message }.
  if (
    req.headers['username'] !== CREDENTIALS.username ||
    req.headers['secret'] !== CREDENTIALS.secret ||
    req.headers['apiintegrationcode'] !== CREDENTIALS.code
  ) {
    res.writeHead(401, { 'content-type': 'application/json' });
    res.end(
      JSON.stringify({
        code: 'AUTHENTICATION_FAILED',
        message: 'Autotask rejected the API user credentials.',
      }),
    );
    return;
  }
  // A client that closes the connection before the response has finished cancels the request.
  const disconnect = new AbortController();
  res.on('close', () => {
    if (!res.writableFinished) disconnect.abort();
  });
  await writeWebResponse(
    res,
    await handler.fetch(toWebRequest(req, body, mcp.port, disconnect.signal)),
  ).catch(() => {});
});

// A server that only counts: the host a redirect, or an endpoint outside autotask.net, would reach.
let otherHits = 0;
const other = await listen((_req, res) => {
  otherHits++;
  res.writeHead(500);
  res.end();
});

// A server whose /mcp answers every request with a redirect to the other origin.
let redirectorHits = 0;
const redirector = await listen((_req, res) => {
  redirectorHits++;
  res.writeHead(307, { location: `http://127.0.0.1:${other.port}/mcp` });
  res.end();
});

// A server that opens an event stream for every request and ends it before any response.
const cut = await listen((_req, res) => {
  res.writeHead(200, { 'content-type': 'text/event-stream' });
  res.end();
});

const HOST_PORTS = JSON.stringify({
  [HOST.mcp]: mcp.port,
  [HOST.redirect]: redirector.port,
  [HOST.cut]: cut.port,
  [HOST.outside]: other.port,
});

/** @param {Record<string, string>} overrides */
function relayEnv(overrides = {}) {
  /** @type {Record<string, string>} */
  const env = {
    AUTOTASK_MCP_ENDPOINT: ENDPOINT,
    AUTOTASK_API_USERNAME: CREDENTIALS.username,
    AUTOTASK_API_SECRET: CREDENTIALS.secret,
    AUTOTASK_API_INTEGRATION_CODE: CREDENTIALS.code,
    RELAY_TEST_HOSTS: HOST_PORTS,
    ...overrides,
  };
  if (process.env['PATH'] !== undefined) env['PATH'] = process.env['PATH'];
  if (process.env['SystemRoot'] !== undefined) env['SystemRoot'] = process.env['SystemRoot'];
  return env;
}

/**
 * What the current case has observed, and the credential values none of it may carry: the relay's
 * stderr and every error the client received.
 *
 * @type {{ texts: (() => string)[], credentialValues: string[] }}
 */
let observed = { texts: [], credentialValues: [] };

/**
 * Starts the relay over stdio and builds a client for it, with the client's version negotiation.
 *
 * @param {NegotiationMode} versionNegotiation
 * @param {Record<string, string>} env
 */
function connect(versionNegotiation, env) {
  for (const name of [
    'AUTOTASK_API_USERNAME',
    'AUTOTASK_API_SECRET',
    'AUTOTASK_API_INTEGRATION_CODE',
  ]) {
    // A value is checked line by line, so a value with a line break is caught in part as well as whole.
    for (const line of (env[name] ?? '').split(/\r?\n/)) {
      if (line !== '') observed.credentialValues.push(line);
    }
  }
  const transport = new StdioClientTransport({
    command: process.execPath,
    args: ['--import', PRELOAD, RELAY],
    env,
    stderr: 'pipe',
  });
  let stderr = '';
  transport.stderr?.on('data', (chunk) => (stderr += chunk));
  observed.texts.push(() => stderr);
  const client = new Client(
    { name: 'conformance', version: '0' },
    { versionNegotiation: { mode: versionNegotiation } },
  );
  return { client, transport };
}

/**
 * Resolves with the error `promise` rejects with, recorded for the credential check, or with undefined
 * when it resolves.
 *
 * @param {Promise<unknown>} promise
 * @returns {Promise<{ message: string } | undefined>}
 */
async function failureOf(promise) {
  try {
    await promise;
    return undefined;
  } catch (error) {
    const text = `${error instanceof Error ? error.message : String(error)} ${JSON.stringify(/** @type {{ data?: unknown }} */ (error)?.data ?? null)}`;
    observed.texts.push(() => text);
    return { message: error instanceof Error ? error.message : String(error) };
  }
}

/** @type {string[]} */
const results = [];
/**
 * @param {string} name
 * @param {() => Promise<void>} body
 */
async function check(name, body) {
  observed = { texts: [], credentialValues: [] };
  /** @type {string[]} */
  const failures = [];
  try {
    await body();
  } catch (error) {
    failures.push(error instanceof Error ? error.message : String(error));
  }
  // Checked whether or not the case passed: a failing case can leak a credential as well.
  const texts = observed.texts.map((read) => read());
  if (observed.credentialValues.some((value) => texts.some((text) => text.includes(value)))) {
    failures.push('a credential value appears on stderr or in an error');
  }
  results.push(failures.length === 0 ? `PASS  ${name}` : `FAIL  ${name}: ${failures.join('; ')}`);
}
/**
 * @param {unknown} condition
 * @param {string} message
 * @returns {asserts condition}
 */
function assert(condition, message) {
  if (!condition) throw new Error(message);
}

/** @typedef {'legacy' | 'auto' | { pin: string }} NegotiationMode */

/** @type {NegotiationMode[]} */
const CONNECT_MODES = ['legacy', { pin: '2026-07-28' }, 'auto'];
/** @type {NegotiationMode[]} */
const CANCEL_MODES = ['legacy', { pin: '2026-07-28' }];

for (const mode of CONNECT_MODES) {
  const label = typeof mode === 'string' ? mode : `pin ${mode.pin}`;
  await check(`${label}: connect, list tools, call a tool`, async () => {
    seen.length = 0;
    const { client, transport } = connect(mode, relayEnv());
    await client.connect(transport);
    const tools = await client.listTools();
    assert(
      tools.tools.some((tool) => tool.name === 'get_ticket'),
      'tools/list missing get_ticket',
    );
    const result = await client.callTool({
      name: 'get_ticket',
      arguments: { ticketNumber: 'T20260928.0001' },
    });
    const content = /** @type {{ type: string, text?: string }[] | undefined} */ (result.content);
    assert(
      content?.[0]?.text === 'ticket T20260928.0001',
      `unexpected result ${JSON.stringify(result)}`,
    );
    const call = seen.find((request) => request.method === 'tools/call');
    assert(call, 'server never received tools/call');
    assert(call.headers['secret'] === CREDENTIALS.secret, 'credential header missing');
    if (label === 'legacy') {
      assert(
        seen.some((request) => request.method === 'initialize'),
        'no initialize on legacy',
      );
      assert(
        call.headers['mcp-protocol-version'] !== undefined,
        'legacy tools/call without MCP-Protocol-Version',
      );
    } else {
      assert(
        call.headers['mcp-method'] === 'tools/call',
        `modern tools/call Mcp-Method = ${call.headers['mcp-method']}`,
      );
      assert(
        call.headers['mcp-name'] === 'get_ticket',
        `modern tools/call Mcp-Name = ${call.headers['mcp-name']}`,
      );
      assert(
        call.headers['mcp-protocol-version'] === '2026-07-28',
        'modern tools/call protocol header',
      );
    }
    await client.close();
  });
}

for (const mode of CANCEL_MODES) {
  const label = typeof mode === 'string' ? mode : `pin ${mode.pin}`;
  await check(`${label}: cancelling a call aborts the server handler`, async () => {
    slowCallAborted = false;
    seen.length = 0;
    const { client, transport } = connect(mode, relayEnv());
    await client.connect(transport);
    const controller = new AbortController();
    const call = client.callTool(
      { name: 'slow_query', arguments: {} },
      { signal: controller.signal },
    );
    setTimeout(() => controller.abort(), 500);
    assert(await failureOf(call), 'call resolved after cancel');
    await new Promise((resolve) => setTimeout(resolve, 500));
    assert(slowCallAborted, 'the server handler never saw the abort');
    const postedCancel = seen.some((request) => request.method === 'notifications/cancelled');
    if (label === 'legacy')
      assert(postedCancel, 'legacy cancel did not POST notifications/cancelled');
    else
      assert(
        !postedCancel,
        'modern cancel POSTed notifications/cancelled, which 2026-07-28 does not define over HTTP',
      );
    await client.close();
  });
}

await check('wrong secret: the server refusal reaches the client', async () => {
  const { client, transport } = connect(
    'legacy',
    relayEnv({ AUTOTASK_API_SECRET: 'wrong-secret' }),
  );
  const error = await failureOf(client.connect(transport));
  assert(error, 'connect succeeded with a wrong secret');
  assert(
    error.message.includes('AUTHENTICATION_FAILED: Autotask rejected the API user credentials.'),
    `message: ${error.message}`,
  );
  await client.close().catch(() => {});
});

await check(
  'settings problem: an endpoint outside autotask.net is refused before any request',
  async () => {
    otherHits = 0;
    const { client, transport } = connect(
      'legacy',
      relayEnv({ AUTOTASK_MCP_ENDPOINT: `https://${HOST.outside}/mcp` }),
    );
    const error = await failureOf(client.connect(transport));
    assert(
      error?.message.includes('is not an Autotask MCP endpoint'),
      `message: ${error?.message}`,
    );
    assert(otherHits === 0, `the outside host received ${otherHits} request(s)`);
    await client.close().catch(() => {});
  },
);

await check('settings problem: a loopback endpoint is refused before any request', async () => {
  const before = seen.length;
  const { client, transport } = connect(
    'legacy',
    relayEnv({ AUTOTASK_MCP_ENDPOINT: `http://127.0.0.1:${mcp.port}/mcp` }),
  );
  const error = await failureOf(client.connect(transport));
  assert(error?.message.includes('is not an Autotask MCP endpoint'), `message: ${error?.message}`);
  assert(seen.length === before, 'the loopback server received a request');
  await client.close().catch(() => {});
});

await check('redirect: credentials never follow a redirect to another origin', async () => {
  otherHits = 0;
  redirectorHits = 0;
  const { client, transport } = connect(
    'legacy',
    relayEnv({ AUTOTASK_MCP_ENDPOINT: `https://${HOST.redirect}/mcp` }),
  );
  const error = await failureOf(client.connect(transport));
  assert(
    redirectorHits > 0,
    'the relay never reached the redirecting endpoint, so the test proved nothing',
  );
  assert(error, 'connect succeeded through a redirect');
  assert(otherHits === 0, `the other origin received ${otherHits} request(s)`);
  await client.close().catch(() => {});
});

await check('pasted twice: the doubled endpoint is named in the error', async () => {
  const doubled = `${ENDPOINT}${ENDPOINT}`;
  const { client, transport } = connect('legacy', relayEnv({ AUTOTASK_MCP_ENDPOINT: doubled }));
  const error = await failureOf(client.connect(transport));
  assert(error?.message.includes(doubled), `message: ${error?.message}`);
  await client.close().catch(() => {});
});

await check('line break: a secret with a line break is named, not quoted', async () => {
  const before = seen.length;
  const { client, transport } = connect(
    'legacy',
    relayEnv({ AUTOTASK_API_SECRET: 'line-one\nline-two' }),
  );
  const error = await failureOf(client.connect(transport));
  assert(
    error?.message.includes('The API secret contains a character an HTTP header cannot carry'),
    `message: ${error?.message}`,
  );
  assert(seen.length === before, 'a request was sent despite the settings problem');
  await client.close().catch(() => {});
});

await check('stream ends early: the client receives an error naming the method', async () => {
  const { client, transport } = connect(
    'legacy',
    relayEnv({ AUTOTASK_MCP_ENDPOINT: `https://${HOST.cut}/mcp` }),
  );
  const error = await failureOf(client.connect(transport));
  assert(
    error?.message.includes('closed the response to initialize before answering it'),
    `message: ${error?.message}`,
  );
  await client.close().catch(() => {});
});

console.log(results.join('\n'));
for (const { server } of [mcp, other, redirector, cut]) server.close();
process.exit(results.some((result) => result.startsWith('FAIL')) ? 1 : 0);
