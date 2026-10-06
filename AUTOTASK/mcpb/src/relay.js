/**
 * The Autotask Claude Desktop extension's server: a relay between Claude Desktop, which speaks MCP over
 * stdio to this process, and one hosted Autotask MCP Regional endpoint, which speaks MCP over Streamable
 * HTTP.
 *
 * Every message passes through the official MCP TypeScript SDK's `StreamableHTTPClientTransport`
 * unchanged, and the stdio side uses the same SDK's message framing, so every rule of the Streamable HTTP
 * revisions is the SDK's, not this file's. The relay neither reads nor rewrites a tool call, a result, or
 * any Autotask data. It adds the following, each for the failure it prevents:
 *
 * - **The credentials go to the endpoint's origin alone, and no redirect is followed**, so a response
 *   cannot steer the credentials to another host.
 * - **The endpoint's host matches `mcp<zone>.autotask.net`, over `https:`**, so a mistyped or suggested
 *   endpoint does not receive the credentials.
 * - **The endpoint's path is `/mcp`, with no query or fragment**, so an endpoint pasted twice is named
 *   rather than reported as a bare `404`.
 * - **Every header value is visible ASCII**, so a secret with a pasted line break does not appear in the
 *   error Node raises, which quotes the invalid value.
 * - **A settings problem answers every request, and the process does not exit**, because Claude Desktop
 *   shows an early exit only as "Server disconnected" and can drop the stderr line that says why.
 * - **Every request gets one answer.** A refusal over HTTP becomes a JSON-RPC error with the server's
 *   `code` and `message`; a stream that ends early and a failed send become an error naming the cause.
 *   Otherwise Claude Desktop waits, or shows a message that names no cause.
 * - **A `notifications/cancelled` closes that request's stream, and on a 2025-era exchange is forwarded
 *   as well**, so the server stops a call the user cancelled.
 * - **The revision a 2025-era `initialize` negotiated is handed to the transport**, so 2025-era requests
 *   carry the right `MCP-Protocol-Version`.
 * - **Diagnostics go to stderr and never carry a credential value**, so no credential reaches the
 *   extension's log. Stdout carries MCP messages alone.
 *
 * The relay sets no request timeout of its own. The server ends every call at its call deadline, the
 * edge in front of it closes a silent connection, and Node's `fetch` stops a request that receives
 * nothing; the relay answers each of these as a failed request.
 */

import {
  PROTOCOL_VERSION_META_KEY,
  ReadBuffer,
  StreamableHTTPClientTransport,
  isInitializeRequest,
  isJSONRPCErrorResponse,
  isJSONRPCNotification,
  isJSONRPCRequest,
  isJSONRPCResultResponse,
  serializeMessage,
} from '@modelcontextprotocol/client';

/** @typedef {import('@modelcontextprotocol/client').JSONRPCMessage} JSONRPCMessage */
/** @typedef {import('@modelcontextprotocol/client').JSONRPCRequest} JSONRPCRequest */
/** @typedef {import('@modelcontextprotocol/client').RequestId} RequestId */

/**
 * The JSON-RPC error code of every error the relay writes on the server's behalf. It sits in the
 * implementation-defined server-error range (-32000 to -32099), so no client mistakes it for an error
 * of the protocol itself.
 */
const RELAY_ERROR_CODE = -32001;

/**
 * The relay's name and version, sent as its `User-Agent`: the edge's access log is where support sees
 * which extension version a customer runs. The build writes the version from `package.json`.
 */
const USER_AGENT = `autotask-mcp-desktop-extension/${RELAY_VERSION}`;

/**
 * The hosts the credentials may be sent to: the Autotask MCP Regional endpoints, `mcp` followed by the
 * zone's own token under `autotask.net` — `mcp3.autotask.net`, `mcpprde.autotask.net`.
 */
const REGIONAL_ENDPOINT_HOST = /^mcp[a-z0-9]*\.autotask\.net$/;

/** Characters an HTTP header value can carry: visible ASCII and the space. */
const HEADER_SAFE_VALUE = /^[\x20-\x7E]*$/;

// ---------------------------------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------------------------------

/**
 * Reads and checks the four settings Claude Desktop passes as environment variables. A problem does not
 * stop the process: the relay stays running and answers every request with the problem.
 */
function readSettings() {
  /** @type {string[]} */
  const problems = [];

  /**
   * @param {string} name
   * @param {string} label
   */
  const read = (name, label) => {
    // The edges are trimmed, as `Headers` trims a value, so a pasted trailing line break is accepted.
    const value = (process.env[name] ?? '').trim();
    if (!HEADER_SAFE_VALUE.test(value)) {
      // The value is not quoted: it may be a credential.
      problems.push(
        `${label} contains a character an HTTP header cannot carry; check what was pasted.`,
      );
      return '';
    }
    return value;
  };

  const endpoint = read('AUTOTASK_MCP_ENDPOINT', 'The Autotask MCP endpoint');
  const credentialHeaders = {
    ApiIntegrationCode: read('AUTOTASK_API_INTEGRATION_CODE', 'The API integration code'),
    UserName: read('AUTOTASK_API_USERNAME', 'The API username'),
    Secret: read('AUTOTASK_API_SECRET', 'The API secret'),
  };

  /** @type {URL | undefined} */
  let endpointUrl;
  try {
    endpointUrl = new URL(endpoint);
  } catch {
    endpointUrl = undefined;
  }
  const isRegional =
    endpointUrl?.protocol === 'https:' && REGIONAL_ENDPOINT_HOST.test(endpointUrl.hostname);
  const isMcpPath =
    endpointUrl?.pathname === '/mcp' && endpointUrl.search === '' && endpointUrl.hash === '';
  if (!isRegional || !isMcpPath) {
    // The endpoint is not a secret, so the message quotes it: a value pasted twice is plain to see.
    problems.push(
      `The Autotask MCP endpoint "${endpoint}" is not an Autotask MCP endpoint. It is https://, then the ` +
        'mcp host for your Autotask zone, then /mcp, like https://mcp3.autotask.net/mcp.',
    );
    endpointUrl = undefined;
  }

  const problem =
    problems.length === 0
      ? undefined
      : `The Autotask extension's settings need attention: ${problems.join(' ')} Open Settings > Extensions > ` +
        'Autotask in Claude Desktop, correct the setting, and restart the extension.';
  return { endpointUrl, credentialHeaders, problem };
}

/**
 * Builds the one `fetch` the transport uses. It adds the credential headers, refuses any URL outside the
 * endpoint's origin, and refuses to follow a redirect, because a redirect to another origin would carry
 * the custom credential headers with it — `fetch` strips `Authorization` on a cross-origin redirect,
 * but not a header it does not know is a credential.
 *
 * @param {URL} endpointUrl
 * @param {Record<string, string>} credentialHeaders
 */
function buildCredentialFetch(endpointUrl, credentialHeaders) {
  /**
   * @param {string | URL | Request} input
   * @param {RequestInit} [init]
   */
  return async (input, init = {}) => {
    const target = new URL(input instanceof Request ? input.url : String(input));
    if (target.origin !== endpointUrl.origin) {
      throw new Error(
        `the relay sends credentials to ${endpointUrl.origin} alone and refused ${target.origin}`,
      );
    }
    const headers = new Headers(init.headers);
    for (const [name, value] of Object.entries(credentialHeaders)) headers.set(name, value);
    headers.set('user-agent', USER_AGENT);
    return fetch(target, { ...init, headers, redirect: 'error' });
  };
}

// ---------------------------------------------------------------------------------------------------
// Messages to Claude Desktop
// ---------------------------------------------------------------------------------------------------

/** @param {JSONRPCMessage} message */
function writeToClaude(message) {
  process.stdout.write(serializeMessage(message));
}

/** @param {string} line */
function log(line) {
  console.error(`autotask-mcp: ${line}`);
}

/**
 * Turns a failed exchange into the message Claude Desktop shows. An admission refusal from the server
 * carries `{ code, message }`, which never holds a credential value, and is shown as the server wrote
 * it; anything else is described by its HTTP status or its network cause.
 *
 * @param {unknown} error
 * @param {URL} endpointUrl
 * @returns {{ message: string, data?: unknown }}
 */
function describeFailure(error, endpointUrl) {
  const errorData = /** @type {{ data?: { status?: unknown, text?: unknown } } | undefined} */ (
    error
  )?.data;
  if (typeof errorData?.status === 'number') {
    const status = errorData.status;
    if (typeof errorData.text === 'string') {
      try {
        const body = JSON.parse(errorData.text);
        if (typeof body?.code === 'string' && typeof body?.message === 'string') {
          return { message: `${body.code}: ${body.message}`, data: body };
        }
      } catch {
        // A body that is not JSON — an edge refusal page — keeps the status-only message.
      }
    }
    return { message: `The Autotask MCP server answered HTTP ${status}.`, data: { status } };
  }
  const cause = /** @type {{ cause?: { message?: unknown } } | undefined} */ (error)?.cause
    ?.message;
  const reason =
    typeof cause === 'string' ? cause : error instanceof Error ? error.message : 'unknown error';
  return {
    message: `Could not reach ${endpointUrl.origin}: ${reason}. Check the network and the endpoint setting.`,
  };
}

// ---------------------------------------------------------------------------------------------------
// The relay
// ---------------------------------------------------------------------------------------------------

/**
 * Whether a request carries the 2026-07-28 per-request envelope. Such a request is cancelled by closing
 * its stream alone; a 2025-era request is cancelled by the notification as well.
 *
 * @param {JSONRPCRequest} request
 */
function isModernRequest(request) {
  const version = request.params?._meta?.[PROTOCOL_VERSION_META_KEY];
  return typeof version === 'string' && version >= '2026-07-28';
}

function startRelay() {
  const { endpointUrl, credentialHeaders, problem } = readSettings();
  log(problem ?? `relaying to ${endpointUrl?.origin}${endpointUrl?.pathname}`);

  /**
   * Every request Claude Desktop sent that has no response yet, by id.
   *
   * @type {Map<RequestId, { controller: AbortController, modern: boolean }>}
   */
  const pending = new Map();
  /**
   * The ids of `initialize` requests, whose result names the revision a 2025-era exchange uses.
   *
   * @type {Set<RequestId>}
   */
  const initializeIds = new Set();

  /**
   * Answers a pending request with an error and forgets it. A request already answered or cancelled is
   * left alone, so Claude Desktop never receives two answers to one request.
   *
   * @param {RequestId} id
   * @param {{ message: string, data?: unknown }} failure
   */
  const answerWithError = (id, failure) => {
    if (!pending.delete(id)) return;
    writeToClaude({ jsonrpc: '2.0', id, error: { code: RELAY_ERROR_CODE, ...failure } });
  };

  // Any settings problem leaves the relay with no transport, so no request is sent with a setting the
  // relay refused.
  const transport =
    problem !== undefined || endpointUrl === undefined
      ? undefined
      : new StreamableHTTPClientTransport(endpointUrl, {
          fetch: buildCredentialFetch(endpointUrl, credentialHeaders),
        });

  if (transport !== undefined) {
    transport.onmessage = (message) => {
      if (isJSONRPCResultResponse(message) || isJSONRPCErrorResponse(message)) {
        // A response to a request that was cancelled is dropped, as the cancellation rules ask: Claude
        // Desktop has already stopped waiting for it. So is an error with no id, which answers nothing
        // Claude Desktop sent.
        if (message.id === undefined || !pending.delete(message.id)) return;
        if (initializeIds.delete(message.id) && isJSONRPCResultResponse(message)) {
          const version = message.result['protocolVersion'];
          if (typeof version === 'string') transport.setProtocolVersion(version);
        }
      }
      writeToClaude(message);
    };
    transport.onerror = (error) => log(`transport: ${error.message.slice(0, 500)}`);
    void transport.start();
  }

  /** @param {JSONRPCRequest} request */
  const relayRequest = (request) => {
    if (transport === undefined || endpointUrl === undefined) {
      writeToClaude({
        jsonrpc: '2.0',
        id: request.id,
        error: { code: RELAY_ERROR_CODE, message: problem ?? '' },
      });
      return;
    }
    const controller = new AbortController();
    pending.set(request.id, { controller, modern: isModernRequest(request) });
    if (isInitializeRequest(request)) initializeIds.add(request.id);

    transport
      .send(request, {
        requestSignal: controller.signal,
        // The response stream ended, with no reconnection left to try, before a response arrived.
        onRequestStreamEnd: () =>
          answerWithError(request.id, {
            message: `The Autotask MCP server closed the response to ${request.method} before answering it.`,
          }),
      })
      .catch((error) => {
        if (!controller.signal.aborted)
          answerWithError(request.id, describeFailure(error, endpointUrl));
      });
  };

  /** @param {JSONRPCMessage} message */
  const relayFromClaude = (message) => {
    if (isJSONRPCRequest(message)) {
      relayRequest(message);
      return;
    }
    if (transport === undefined) return;
    if (isJSONRPCNotification(message) && message.method === 'notifications/cancelled') {
      const requestId = /** @type {RequestId | undefined} */ (message.params?.['requestId']);
      const entry = requestId === undefined ? undefined : pending.get(requestId);
      if (requestId !== undefined && entry !== undefined) {
        pending.delete(requestId);
        entry.controller.abort();
        // The 2026-07-28 revision defines no client notification over HTTP: the closed stream is the
        // cancellation. A 2025-era exchange asks for the notification itself.
        if (entry.modern) return;
      }
    }
    // A notification, or a response to a request the server made on a 2025-era exchange.
    transport.send(message).catch(() => {
      // The transport has already reported the failure through `onerror`, and no request awaits it.
    });
  };

  const readBuffer = new ReadBuffer();
  process.stdin.on('data', (chunk) => {
    try {
      readBuffer.append(chunk);
    } catch (error) {
      // A message over the SDK's 10 MB framing limit: the buffer is cleared and the message is lost.
      log(
        `dropped input from Claude Desktop (${error instanceof Error ? error.message : 'error'})`,
      );
      return;
    }
    // `readMessage` consumes each line before parsing it, so a line that is not an MCP message is
    // skipped rather than read again.
    for (;;) {
      /** @type {JSONRPCMessage | null} */
      let message;
      try {
        message = readBuffer.readMessage();
      } catch (error) {
        log(
          `ignored a line from Claude Desktop that is not an MCP message (${error instanceof Error ? error.name : 'error'})`,
        );
        continue;
      }
      if (message === null) break;
      relayFromClaude(message);
    }
  });

  process.stdin.on('end', () => {
    // Claude Desktop closed the connection: stop every request, close the transport, and exit, as the
    // stdio transport asks of a server whose input has closed.
    for (const entry of pending.values()) entry.controller.abort();
    pending.clear();
    const shutdown = transport === undefined ? Promise.resolve() : transport.close();
    void shutdown.finally(() => process.exit(0));
  });
}

startRelay();
