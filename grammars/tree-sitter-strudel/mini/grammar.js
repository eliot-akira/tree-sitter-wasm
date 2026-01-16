/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "strudel_mini",

  extras: $ => [
    /[\s\n]/,
  ],

  rules: {
    // A pattern is a sequence of steps
    source_file: $ => repeat($._expression),

    _expression: $ => choice(
      $.step,
      $.group,
      $.polyphony,
      $.alternation,
      $.polymeter,
    ),

    // A basic step (note, sample, rest)
    step: $ => seq(
      choice($.identifier, $.number, $.rest),
      optional($.modifier)
    ),

    // Modifiers attached to steps or groups: *2, /4, (3,8)
    modifier: $ => choice(
      $.speed_modifier,
      $.euclidean_modifier
    ),

    speed_modifier: $ => seq(
      choice('*', '/'),
      $.number
    ),

    euclidean_modifier: $ => seq(
      '(',
      $.number,
      ',',
      $.number,
      optional(seq(',', $.number)), // Optional rotation? (3,8,1)
      ')'
    ),

    // [ a b c ]
    group: $ => seq(
      '[',
      repeat($._expression),
      ']',
      optional($.modifier)
    ),

    // [ a, b, c ] - Polyphony / Stack
    // Note: In Strudel/Tidal, [a,b] is distinct from [a b].
    // [a b] is sequential. [a,b] is parallel.
    // Usually handled by checking for commas.
    polyphony: $ => seq(
      '[',
      seq($._expression, ',', repeat1(seq(optional(','), $._expression))),
      ']',
      optional($.modifier)
    ),

    // < a b c > - Alternation
    alternation: $ => seq(
      '<',
      repeat($._expression),
      '>',
      optional($.modifier)
    ),

    // { a, b, c } - Polymeter
    polymeter: $ => seq(
      '{',
      repeat(choice($._expression, ',')), // Commas optional/structural in polymeter?
      '}',
      optional($.modifier)
    ),

    identifier: $ => /[a-zA-Z0-9#_]+/, // e.g. "bd", "c#4", "808"
    number: $ => /\d+(\.\d+)?/,
    rest: $ => '~',
  }
});
