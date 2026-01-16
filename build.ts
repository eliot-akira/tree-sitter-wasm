import { $ } from 'bun'
import fs from 'node:fs/promises'
import path from 'node:path'

for (const lang of [
  'ada',
  'asciidoc',
  'arduino',
  'awk',
  'bash',
  'c-sharp',
  'c',
  'clojure',
  'cmake',
  'commonlisp',
  'cpp',
  'css',
  'csv',
  'd',
  'dart',
  'diff',
  'djot',
  'dockerfile',
  'elisp',
  // 'diff',
  'elixir',
  'elsa',
  'elm', // Compile error
  'embedded-template',
  'erlang',
  'faust',
  'fennel',
  'forth',
  'fortran',
  'fsharp',
  'glsl',
  'go',
  'haskell',
  'haxe',
  // 'hjson',
  'html',
  'janet',
  'java',
  'javascript',
  'jsdoc',
  'json',
  'json5',
  'jsonnet',
  'julia',
  'kotlin',
  'latex',
  'lean',
  'lua',
  'lilypond',
  'lilypond-scheme',
  'make',
  'markdown', // 'markdown-inline',
  'matlab',
  'nim',
  'nix',
  'ocaml',
  'odin',
  'pascal',
  // 'perl',
  'php',
  'prolog',
  'psv',
  'pug',
  'python',
  'r',
  'racket',
  'regex',
  'riscv',
  'ruby',
  'rust',
  'scala',
  'scheme',
  'scss',
  'sql',
  'strudel',
  'swift',
  'tcl',
  'toml',
  'tsv',
  'typescript',
  'uxntal',
  'wat',
  'xml',
  'yaml',
  'zig',
]) {
  const targetFile = `docs/tree-sitter-${lang}.wasm`

  try {
    await fs.access(targetFile)
    console.log('Target exists:', targetFile)
    continue
  } catch (e) {
    // Fall-through to actually compile
  }

  console.log('Compile language:', lang)

  // These languages ship with precompiled Wasm
  if (lang === 'ocaml' || lang === 'php' || lang === 'typescript') {
    await $`cp node_modules/tree-sitter-${lang}/*.wasm docs`
    continue
  }

  const folderName =
    lang === 'csv' || lang === 'psv' || lang === 'tsv'
      ? `tree-sitter-csv/${lang}`
      : lang === 'dart'
      ? `@sengac/tree-sitter-dart`
      : lang === 'latex'
      ? `@pfoerster/tree-sitter-latex`
      : lang === 'lilypond' || lang === 'lilypond-scheme'
      ? `tree-sitter-lilypond/${lang}`
      : lang === 'markdown' || lang === 'markdown-inline'
      ? `@tree-sitter-grammars/tree-sitter-markdown/tree-sitter-${lang}`
      : lang === 'matlab'
      ? `@acristoffers/tree-sitter-matlab`
      : lang === 'prolog'
      ? `tree-sitter-prolog/grammars/prolog`
      : lang === 'r'
      ? `@eagleoutice/tree-sitter-r`
      : lang === 'sql'
      ? `@derekstride/tree-sitter-sql`
      : lang === 'strudel'
      ? `tree-sitter-strdl`
      : // Under org @tree-sitter-grammars
      lang === 'lua' ||
        // lang === 'markdown' ||
        // lang === 'xml' ||
        lang === 'yaml' ||
        lang === 'zig'
      ? `@tree-sitter-grammars/tree-sitter-${lang}`
      : lang === 'xml'
      ? `@tree-sitter-grammars/tree-sitter-xml/xml`
      : `tree-sitter-${lang}`
  for await (const line of $`bunx tree-sitter build --wasm node_modules/${folderName} --output ${targetFile}`.lines()) {
    if (line.trim()) console.log(line)
  }
}

for (const file of [
  // tree-sitter/lib/binding_web/README.md
  'web-tree-sitter.js',
  'web-tree-sitter.js.map',
  'web-tree-sitter.wasm',
  // 'web-tree-sitter.wasm.map',
  // 'web-tree-sitter.d.ts',
  // 'web-tree-sitter.d.ts.map',
]) {
  console.log('Copy', file)
  await fs.copyFile(`node_modules/web-tree-sitter/${file}`, `docs/${file}`)
}

// Clean up file permissions
// $.cwd = path.join(process.cwd(), 'docs')
// await $`find . -type f -exec chmod 644 {} \\;`
