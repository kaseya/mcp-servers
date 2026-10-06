/**
 * Fails when `manifest.json` names a different version than `package.json`. The version lives in
 * `package.json`, and the build writes it into the relay; Claude Desktop reads the manifest's version
 * as a literal, so the manifest keeps a copy that this check holds equal.
 */

import { readFile } from 'node:fs/promises';

/** @param {string} file */
const readVersion = async (file) =>
  JSON.parse(await readFile(new URL(`../${file}`, import.meta.url), 'utf8')).version;

const packageVersion = await readVersion('package.json');
const manifestVersion = await readVersion('manifest.json');
if (packageVersion !== manifestVersion) {
  console.error(
    `manifest.json names version ${manifestVersion}, but package.json names ${packageVersion}. Set both to one version.`,
  );
  process.exit(1);
}
console.log(`manifest.json and package.json both name version ${packageVersion}`);
