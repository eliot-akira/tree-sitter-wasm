# tree-sitter-strdl

![npm version](https://img.shields.io/npm/v/tree-sitter-strdl?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green)

A [Tree-sitter](https://tree-sitter.github.io/tree-sitter/) parser for **[Strudel](https://strudel.cc/)**, a port of the Tidal Cycles live coding environment to JavaScript.

This project provides robust syntax highlighting and parsing for:
1.  **Strudel DSL**: The core JavaScript-like chainable syntax (e.g., `s("bd").fast(2)`).
2.  **Mini-Notation**: The internal pattern language inside strings (e.g., `"bd*2 [sn cp]"`), parsed via a dedicated secondary grammar (`strdl_mini`) and injected automatically.

---

## ✨ Features

-   **Complete DSL Parsing**: Covers variable declarations, function chaining, and object/array literals.
-   **Mini-Notation Injection**: Strings passed to pattern functions (`s`, `note`, `stack`, etc.) are parsed as a separate language, enabling detailed highlighting of beats, groups, and modifiers.
-   **Neovim Ready**: Includes queries for highlighting, injections, and locals.
-   **Multi-Language Bindings**: Node.js, Rust, Python, Go, Swift, C.

---

## 📦 Installation (NPM)

The grammar is available on npm:

```bash
npm i tree-sitter-strdl
```

This is useful if you are building a tool that uses the grammar (like a VS Code extension or a language server) and want to consume the pre-built WASM or Node bindings.

---

## 🚀 Neovim Integration

To get full highlighting (DSL + Mini-Notation) in Neovim, you need to register both parsers and configure filetype detection.

### 1. Configuration
Add the following Lua code to your `init.lua` or a separate module (e.g., `lua/plugins/strudel.lua`):

> **Note**: If you want to use the stable release from npm instead of building locally, see the "Install from NPM" section below.

```lua
-- 1. Register Parsers (Main + Mini)
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

-- Main Strudel Parser
parser_config.strudel = {
  install_info = {
    url = "~/path/to/tree-sitter-strdl", -- ⚠️ Change this to your local path
    files = { "src/parser.c" },
    branch = "main",
  },
  filetype = "strdl",
}

-- Mini-Notation Parser (for inside strings)
parser_config.strudel_mini = {
  install_info = {
    url = "~/path/to/tree-sitter-strdl/mini", -- ⚠️ Change this to your local path (mini subdir)
    files = { "src/parser.c" },
    branch = "main",
  },
  filetype = "strdl_mini",
}

-- 2. Filetype Detection
vim.filetype.add({
  extension = {
    str = "strdl",
    strdl = "strdl",
    strudel = "strdl",
  },
})

-- 3. Configure nvim-treesitter
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})
```

### 2. Install Queries
To make the highlighting and injections work, copy the query files (`highlights.scm`, `injections.scm`) to your Neovim runtime.

Run this command from the repo root:
```bash
npm run local_install
```
*(This script copies `queries/*.scm` to `~/.local/share/nvim/lazy/nvim-treesitter/queries/strudel`)*

### 3. Verify
1.  Restart Neovim.
2.  Open a `.strdl` file.
3.  Run `:TSInstall strudel` and `:TSInstall strudel_mini` (if not installed automatically).
4.  Type `s("bd*4 [sn cp]")`. You should see distinct highlighting inside the string.

---

## 🛠️ Development

### Prerequisites
-   Node.js & npm
-   Tree-sitter CLI (`cargo install tree-sitter-cli` or via npm)
-   C Compiler (clang/gcc)

### Common Commands

| Task | Command |
| :--- | :--- |
| **Install Deps** | `npm install` |
| **Playground** | `npm start` (Builds WASM & opens browser) |
| **Test (Main)** | `npm test` (Runs corpus tests for DSL) |
| **Test (Mini)** | `npm run test:mini` (Runs corpus tests for mini-notation) |
| **Gen (Main)** | `npx tree-sitter generate` |
| **Gen (Mini)** | `npm run generate:mini` |

### Repository Structure

-   **`grammar.js`**: Definition of the main Strudel language.
-   **`mini/grammar.js`**: Definition of the Mini-Notation language.
-   **`queries/`**: Tree-sitter queries for Neovim.
    -   `highlights.scm`: Syntax coloring rules.
    -   `injections.scm`: Logic to inject `strdl_mini` into specific function calls.
-   **`test/corpus/`**: Test cases for the main language.
-   **`mini/test/corpus/`**: Test cases for the mini-notation.

---

## 🧠 Architecture & Injections

The parser uses Tree-sitter's [Language Injection](https://tree-sitter.github.io/tree-sitter/syntax-highlighting#language-injection) system.

1.  The **Main Parser** identifies function calls like `s("...")`, `note("...")`, `stack("...")`.
2.  The **Injection Query** (`queries/injections.scm`) matches these specific function names.
3.  It marks the string content as `injection.content` and requests the `strdl_mini` language.
4.  The **Mini Parser** takes over for that range, parsing the beats, rests, and modifiers.

**Supported Injection Functions:**
`s`, `sound`, `n`, `note`, `scale`, `chord`, `arp`, `gain`, `speed`, `pan`, `cutoff`, `lpf`, `hpf`, `hpq`, `delay`, `rev`, `stack`, `cat`.

---

## 📚 References

-   [Strudel Website](https://strudel.cc/)
-   [Tidal Cycles](https://tidalcycles.org/)
-   [Tree-sitter Documentation](https://tree-sitter.github.io/tree-sitter/)

---

> Maintained fork of Strudel Tree Sitter Grammar by [Pedro Zappa](https://github.com/PedroZappa/tree-sitter-strdl) — extends grammar beyond upstream v1.1.8; actively maintained for LSP, Neovim plugin, diagnostics, etc.

