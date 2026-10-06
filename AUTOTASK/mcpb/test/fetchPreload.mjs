/**
 * Loaded into the relay with `node --import` by the conformance test, before the relay starts. It
 * replaces the global `fetch` with one that sends each test host under `autotask.net` to its fake server
 * on loopback, so the relay's own host, path, and origin checks run on a real `https://mcp…autotask.net`
 * endpoint while no request reaches the network.
 *
 * `RELAY_TEST_HOSTS` maps each test host to its fake server's port, as JSON. A request to a mapped host
 * is rewritten to `http://127.0.0.1:<port>` with its path and every other argument unchanged —
 * `redirect: 'error'` included, so a redirect is handled exactly as the relay asked. A request to a
 * loopback address passes through unchanged, so a test can tell whether the relay sent one. A request
 * to any other host is refused.
 */

/** @type {Record<string, number>} */
const hostPorts = JSON.parse(process.env['RELAY_TEST_HOSTS'] ?? '{}');
const realFetch = globalThis.fetch;

/**
 * @param {string | URL | Request} input
 * @param {RequestInit} [init]
 */
async function testFetch(input, init) {
  const url = new URL(input instanceof Request ? input.url : String(input));
  const port = hostPorts[url.hostname];
  if (port !== undefined) {
    const rewritten = new URL(`${url.pathname}${url.search}`, `http://127.0.0.1:${port}`);
    return realFetch(rewritten, init);
  }
  if (url.hostname === '127.0.0.1') return realFetch(url, init);
  throw new Error(`the test preload refuses ${url.origin}, which is no test host`);
}

Object.assign(globalThis, { fetch: testFetch });
