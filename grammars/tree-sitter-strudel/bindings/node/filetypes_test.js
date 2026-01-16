const assert = require('node:assert');
const { test } = require('node:test');
const pkg = require('../../package.json');

test('tree-sitter file-types include .str', () => {
  const entries = pkg['tree-sitter'] || [];
  assert.ok(entries.length > 0, 'tree-sitter metadata missing');
  const files = entries[0]['file-types'] || [];
  assert.ok(files.includes('str'), 'Expected file-types to include "str"');
});
