import js from '@eslint/js';
import globals from 'globals';

export default [
  // dist/ is the esbuild bundle of src/, linted as its source.
  { ignores: ['dist/**', 'node_modules/**'] },
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2023,
      sourceType: 'module',
      globals: globals.node,
    },
    rules: {
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },
  {
    files: ['src/relay.js'],
    // Written into the bundle by scripts/build.mjs, and declared for the type check in src/globals.d.ts.
    languageOptions: { globals: { RELAY_VERSION: 'readonly' } },
  },
];
