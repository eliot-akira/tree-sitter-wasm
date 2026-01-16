; ---------------------------------------------------------------------------
;  Strudel locals.scm - Scope resolution for semantic highlighting
; ---------------------------------------------------------------------------
;  Used by tree-sitter for:
;  1. Distinguishing variable definitions from references
;  2. Proper scoping for semantic analysis
;  3. Enhanced syntax highlighting based on context
; ---------------------------------------------------------------------------

; ──────────────────────────────────────────────────────────────────────────
; Scopes - Define lexical scoping boundaries
; ──────────────────────────────────────────────────────────────────────────

[
  (source_file)
  (arrow_function)
  (object)
  (array)
] @local.scope

; ──────────────────────────────────────────────────────────────────────────
; Definitions - Where variables/functions are declared
; ──────────────────────────────────────────────────────────────────────────

; Variable declarations with var/let/const
(variable_declarator
  name: (identifier) @local.definition.var)

; Assignment expressions (including $: patterns)
(assignment
  (identifier) @local.definition.var)

; Arrow function parameters
(arrow_function
  parameter: (identifier) @local.definition.parameter)

; Object property definitions
(pair
  key: (identifier) @local.definition.property)

; Function call identifiers (when they define something in context)
(function_call
  (identifier) @local.definition.function)

; ──────────────────────────────────────────────────────────────────────────
; References - Where variables/functions are used
; ──────────────────────────────────────────────────────────────────────────

; All identifiers are potential references
(identifier) @local.reference

