; ---------------------------------------------------------------------------
;  Strudel mini-notation injections scaffold
;  Inject a future 'strdl-mini' grammar into strings passed to pattern fns
;  Seed functions: s, sound, n, note, scale, chord, arp, gain, speed, pan,
;                  cutoff, lpf, hpf, hpq, delay, rev, stack, cat
; ---------------------------------------------------------------------------

((function_call
  (identifier) @fname
  (_ (string) @injection.content))
 (#any-of? @fname "s" "sound" "n" "note" "scale" "chord" "arp" "gain" "speed" "pan" "cutoff" "lpf" "hpf" "hpq" "delay" "rev" "stack" "cat")
 (#set! injection.language "strdl-mini")
 (#offset! @injection.content 1 0 -1 0))

((method_call
  (identifier) @mname
  (_ (string) @injection.content))
 (#any-of? @mname "s" "sound" "n" "note" "scale" "chord" "arp" "gain" "speed" "pan" "cutoff" "lpf" "hpf" "hpq" "delay" "rev" "stack" "cat")
 (#set! injection.language "strdl-mini")
 (#offset! @injection.content 1 0 -1 0))
