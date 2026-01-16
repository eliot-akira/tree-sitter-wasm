#!/usr/bin/env node

/**
 * Generate domain-specific Tree-sitter highlight captures for Strudel methods/functions
 * using Strudel LS data sources (builtins.json and sounds.json).
 *
 * Usage:
 *   node scripts/generate_domain_queries.js \
 *     --builtins /path/to/strudel-ls/packages/strudel-ls/src/data/builtins.json \
 *     --sounds   /path/to/strudel-ls/packages/strudel-ls/src/data/sounds.json \
 *     --highlights queries/highlights.scm
 *
 * Notes:
 * - We only use builtins.json to generate function/method name lists.
 * - sounds.json is accepted for future use (e.g. injection-level highlighting), but not required now.
 */

const fs = require('fs');
const path = require('path');

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--builtins') args.builtins = argv[++i];
    else if (a === '--sounds') args.sounds = argv[++i];
    else if (a === '--highlights') args.highlights = argv[++i];
    else {
      // support KEY=VALUE style
      const eq = a.indexOf('=');
      if (eq > 0) args[a.slice(0, eq)] = a.slice(eq + 1);
    }
  }
  return args;
}

function readJSON(p) {
  if (!p) return null;
  const raw = fs.readFileSync(p, 'utf8');
  return JSON.parse(raw);
}

function toIdentifierList(entries) {
  const set = new Set();
  const isIdent = s => /^[A-Za-z_][A-Za-z0-9_]*$/.test(s);
  for (const e of entries) {
    if (e && typeof e.name === 'string' && isIdent(e.name)) set.add(e.name);
    if (Array.isArray(e.synonyms)) {
      for (const s of e.synonyms) if (typeof s === 'string' && isIdent(s)) set.add(s);
    }
    if (typeof e.aliasOf === 'string' && isIdent(e.aliasOf)) set.add(e.aliasOf);
  }
  return Array.from(set).sort();
}

function chunk(arr, size) {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

function buildAnyOfCapture(kind, capture, names, priority = 120) {
  // kind: 'function_call' | 'method_call'
  // capture: '@function.call' | '@method'
  const node = kind === 'function_call' ? 'function_call' : 'method_call';
  const idCapture = kind === 'function_call' ? '(identifier) ' : '(identifier) ';
  const predicateName = capture.replace('@', '');
  const chunks = chunk(names, 80);
  const blocks = chunks.map(list => {
    const quoted = list.map(n => `"${n}"`).join(' ');
    return `((` + node + `\n  (identifier)   ${capture})\n  (#any-of? ${capture} ${quoted})\n  (#set! "priority" ${priority}))`;
  });
  return blocks.join('\n\n');
}

function insertOrReplaceGeneratedBlock(hlsPath, block) {
  const startMarker = '; BEGIN: AUTO-GENERATED DOMAIN CAPTURES';
  const endMarker = '; END: AUTO-GENERATED DOMAIN CAPTURES';
  let text = fs.readFileSync(hlsPath, 'utf8');

  const startIdx = text.indexOf(startMarker);
  const endIdx = text.indexOf(endMarker);

  const wrapped = `${startMarker}\n${block}\n${endMarker}\n`;

  if (startIdx !== -1 && endIdx !== -1 && endIdx > startIdx) {
    // replace existing block
    const before = text.slice(0, startIdx);
    const after = text.slice(endIdx + endMarker.length);
    text = before + wrapped + after;
  } else {
    // insert before the fallback (identifier) @variable if present, else append
    const fallbackRE = /(\n|^)\(identifier\)\s*@variable\s*$/m;
    const match = text.match(fallbackRE);
    if (match) {
      const idx = match.index;
      text = text.slice(0, idx) + wrapped + text.slice(idx);
    } else {
      if (!text.endsWith('\n')) text += '\n';
      text += '\n' + wrapped;
    }
  }

  fs.writeFileSync(hlsPath, text, 'utf8');
}

(function main() {
  const { builtins, sounds, highlights } = parseArgs(process.argv);
  if (!builtins || !highlights) {
    console.error('Usage: node scripts/generate_domain_queries.js --builtins path/to/builtins.json --highlights queries/highlights.scm [--sounds path/to/sounds.json]');
    process.exit(2);
  }
  const builtinsData = readJSON(builtins);
  if (!Array.isArray(builtinsData)) {
    console.error('builtins.json did not parse to an array');
    process.exit(3);
  }

  const names = toIdentifierList(builtinsData);
  if (names.length === 0) {
    console.error('No identifiers extracted from builtins.json');
    process.exit(4);
  }

  const functionBlocks = buildAnyOfCapture('function_call', '@function.call', names, 120);
  const methodBlocks = buildAnyOfCapture('method_call', '@method', names, 120);
  const methodLegacyBlocks = buildAnyOfCapture('method_call', '@function.method', names, 119);

  const block = [
    '; Domain-specific identifiers from Strudel LS builtins.json',
    '; This block is auto-generated. Do not edit by hand.',
    functionBlocks,
    methodBlocks,
    methodLegacyBlocks,
  ].join('\n');

  insertOrReplaceGeneratedBlock(highlights, block);
  console.log(`Generated domain captures for ${names.length} identifiers into ${highlights}`);
})();