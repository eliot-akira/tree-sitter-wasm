# tree-sitter-wasm

This is the [tree-sitter](https://github.com/tree-sitter/tree-sitter/) parser and a collection of language grammars compiled to WebAssembly.

## Current

- [x] Build tree-sitter parser
- [x] Build language grammars
- [x] Prepare examples
- [ ] Documentation

## Languages

- `arduino`
- `awk`
- `bash`
- `c-sharp`
- `c`
= `clojure`
- `commonlisp`
- `cpp`
- `css`
- `csv`
- `d`
- `dart`
- `diff`
- `dockerfile`
- `elisp`
- `elixir`
- `elsa`
- `embedded-template`
- `forth`
- `go`
- `haskell`
- `haxe`
- `html`
- `java`
- `javascript`
- `jsdoc`
- `json`
- `julia`
- `kotlin`
- `latex`
- `lean`
- `lua`
- `make`
- `markdown`
- `matlab`
- `nim`
- `nix`
- `ocaml`
- `odin`
- `pascal`
- `php`
- `prolog`
- `pug`
- `psv`
- `python`
- `r`
- `racket`
- `regex`
- `riscv`
- `ruby`
- `rust`
- `scala`
- `scheme`
- `scss`
- `strudel`
- `sql`
- `swift`
- `tcl`
- `toml`
- `tsv`
- `typescript`
- `uxntal`
- `wat`
- `xml`
- `yaml`
- `zig`

## Develop

Install dependencies.

```bash
bun install
```

Build Wasm binaries.

```bash
bun run build.ts
```

## Reference

- [tree-sitter web binding](https://github.com/tree-sitter/tree-sitter/tree/master/lib/binding_web#readme)
