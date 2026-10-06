/**
 * Bundles the relay and its one dependency, the official MCP TypeScript SDK client, into
 * `dist/relay.cjs`, so the extension ships one file and no `node_modules`. The bundle carries the
 * version from `package.json` as `RELAY_VERSION`.
 *
 * It then writes `dist/THIRD_PARTY_NOTICES.txt` with the license text of every package the bundle
 * contains, which their licenses require of anyone who redistributes them, and fails when a bundled
 * package's license is not one of {@link ALLOWED_LICENSES}. The bundle is the whole of what ships, so
 * the packages it drew from are exactly the ones whose licenses bind the extension.
 */

import { build } from 'esbuild';
import { readFile, readdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

/**
 * The licenses a bundled package may carry: permissive licenses that allow redistribution in a
 * proprietary or open-source build alike, provided the notice ships with it.
 */
const ALLOWED_LICENSES = new Set([
  'MIT',
  'Apache-2.0',
  'BSD-2-Clause',
  'BSD-3-Clause',
  '0BSD',
  'ISC',
]);

const extensionRoot = fileURLToPath(new URL('..', import.meta.url));
const { version } = JSON.parse(await readFile(path.join(extensionRoot, 'package.json'), 'utf8'));

const result = await build({
  entryPoints: [path.join(extensionRoot, 'src', 'relay.js')],
  outfile: path.join(extensionRoot, 'dist', 'relay.cjs'),
  bundle: true,
  platform: 'node',
  target: 'node20',
  format: 'cjs',
  define: { RELAY_VERSION: JSON.stringify(version) },
  legalComments: 'eof',
  metafile: true,
  logLevel: 'warning',
});

/** The package directories the bundle drew files from, nearest `node_modules` segment first. */
const packageDirectories = new Set();
for (const input of Object.keys(result.metafile.inputs)) {
  const segments = input.split('/');
  const index = segments.lastIndexOf('node_modules');
  if (index === -1) continue;
  const nameLength = segments[index + 1]?.startsWith('@') ? 2 : 1;
  packageDirectories.add(segments.slice(0, index + 1 + nameLength).join('/'));
}

const notices = [];
/** @type {string[]} */
const refused = [];
/** `name@version` of every package already noted: two installed copies of one release get one notice. */
const noted = new Set();
for (const directory of [...packageDirectories].sort()) {
  const absolute = path.join(extensionRoot, directory);
  const manifest = JSON.parse(await readFile(path.join(absolute, 'package.json'), 'utf8'));
  if (noted.has(`${manifest.name}@${manifest.version}`)) continue;
  noted.add(`${manifest.name}@${manifest.version}`);
  if (!ALLOWED_LICENSES.has(manifest.license)) {
    refused.push(
      `${manifest.name}@${manifest.version} (${manifest.license ?? 'no license field'})`,
    );
  }
  const licenseFile = (await readdir(absolute)).find((file) =>
    /^(licen[cs]e|copying)(\.|$)/i.test(file),
  );
  const licenseText =
    licenseFile === undefined
      ? '(no license file in the package)'
      : await readFile(path.join(absolute, licenseFile), 'utf8');
  notices.push(
    `${manifest.name}@${manifest.version} — ${manifest.license}\n\n${licenseText.trim()}\n`,
  );
}

if (refused.length > 0) {
  console.error(
    `the bundle contains packages whose license is not ${[...ALLOWED_LICENSES].join(', ')}:\n  ${refused.join('\n  ')}`,
  );
  process.exit(1);
}

await writeFile(
  path.join(extensionRoot, 'dist', 'THIRD_PARTY_NOTICES.txt'),
  `The Autotask Claude Desktop extension bundles the following packages.\n\n${notices.join('\n' + '-'.repeat(78) + '\n\n')}`,
);
console.log(
  `bundled dist/relay.cjs ${version} with ${noted.size} third-party package(s); notices written`,
);
