; ---------------------------------------------------------------------------
;  Strudel syntax-highlighting rules
; ---------------------------------------------------------------------------
;  CAPTURE NAMING
;  1.  Specific > generic – put the most specific patterns first.
;  2.  Use the standard highlight names recognised by tree-sitter-highlight[10].
; ---------------------------------------------------------------------------

; ──────────────────────────────────────────────────────────────────────────
; Keywords
; ──────────────────────────────────────────────────────────────────────────

[
  "$:"           ; default assignment prefix
  "var"          ; variable declaration
  "let"
  "const"
] @keyword

; ──────────────────────────────────────────────────────────────────────────
; Punctuation & Delimiters
; ──────────────────────────────────────────────────────────────────────────
[
  "."
  ","
  ":"
  ";"
] @punctuation.delimiter

; Brackets
[
  "("
  ")"
] @punctuation.bracket

[
  "["
  "]"
] @punctuation.bracket

[
  "{"
  "}"
] @punctuation.bracket

; ──────────────────────────────────────────────────────────────────────────
; Arithmetic Operators (Binary Expressions)
; ──────────────────────────────────────────────────────────────────────────
; Capture arithmetic operators from binary expressions
(additive_expression
  operator: _ @operator)

(multiplicative_expression
  operator: _ @operator)

; Alternative approach - directly capture operator literals
"+"              @operator
"-"              @operator
"*"              @operator
"/"              @operator

; ──────────────────────────────────────────────────────────────────────────
; Literals
; ──────────────────────────────────────────────────────────────────────────
(string)         @string
(number)         @number
(comment)        @comment

; ──────────────────────────────────────────────────────────────────────────
; Identifiers (Functions & Vars)
; ──────────────────────────────────────────────────────────────────────────
; 1. Function call identifiers
((function_call
  (identifier)   @function.call)
  (#set! "priority" 110))

; 2. Method call identifiers (after the dot)
((method_call
  (identifier)   @method)
  (#set! "priority" 110))

; 3. Variable declarations: names on the LHS
(variable_declarator
  name: (identifier) @variable)

; 4. Special Strudel function calls
; Core control functions
(function_call
  (identifier) @function.control
  (#any-of? @function.control "setCps" "setCpm" "setTempo" "setBpm"))

; Audio functions (samples and sounds)
(function_call
  (identifier) @function.audio
  (#any-of? @function.audio "samples" "sound" "s" "note" "n" "freq"))

; Pattern generation functions
(function_call
  (identifier) @function.pattern
  (#any-of? @function.pattern "scale" "chord" "pattern" "seq" "sequence" "stack"
    "layer" "cat" "append" "add" "mul" "div" "sub" "fast" "slow" "speed" "iter"
    "every" "sometimes" "rarely" "often" "jux" "juxBy" "rev" "palindrome" "shuffle")
  )

; Effects functions (filters and audio effects)
(function_call
  (identifier) @function.effect
  (#any-of? @function.effect "lpf" "hpf" "bpf" "lpq" "hpq" "bpq" "cutoff" "resonance"
    "filter" "reverb" "rev" "delay" "room" "size" "echo" "phaser" "crush" "coarse"
    "distort" "dist" "vowel" "pan" "gain" "velocity" "attack" "decay" "sustain"
    "release" "adsr")
  )

; Amplitude and envelope functions
(function_call
  (identifier) @function.envelope
  (#any-of? @function.envelope "att" "dec" "sus" "rel" "penv" "lpenv" "hpenv" 
    "bpenv" "tremolo" "am" "compressor"))

; Time manipulation functions
(function_call
  (identifier) @function.time
  (#any-of? @function.time "fast" "slow" "hurry" "linger" "trunc" "mask" "struct" 
    "euclidean" "swing" "late" "early")
  )

; Utility and special functions
(function_call
  (identifier) @function.utility
  (#any-of? @function.utility "silence" "rest" "_" "choose" "choose" "chooseInWith" 
    "range" "run" "scan" "sine" "cosine" "saw" "square" "rand" "perlin")
  )

; MIDI and control functions
(function_call
  (identifier) @function.midi
  (#any-of? @function.midi "midi" "ccv" "ccn" "bend" "program" "bank" "ch" 
    "channel" "polyTouch" "polyAftertouch")
  )

; Sample manipulation functions
(function_call
  (identifier) @function.sample
  (#any-of? @function.sample "begin" "end" "loop" "chop" "striate" "slice" 
    "splice" "speed" "unit" "coarse")
  )

; 5. All remaining identifiers default to variable

; ──────────────────────────────────────────────────────────────────────────
; Expressions & Chains
; ──────────────────────────────────────────────────────────────────────────
; Highlight the leading identifier of a chained method sequence
((chained_method
  (_
    .
    (identifier) @method))
  (#set! "priority" 110))

(arrow_function
  parameter: (identifier) @variable.parameter
  body: (expression))

; ──────────────────────────────────────────────────────────────────────────
; Variable Declarations & Assignments
; ──────────────────────────────────────────────────────────────────────────

; Variable declarations: names on the LHS
(variable_declarator
  name: (identifier) @variable)

; Assignment expressions
(assignment
  (identifier) @variable)

; Object property keys
(pair
  key: (identifier) @property)

(pair
  key: (string) @property)

(pair
  key: (number) @property)

; ──────────────────────────────────────────────────────────────────────────
; Expression Context Highlighting
; ──────────────────────────────────────────────────────────────────────────

; Highlight binary expressions for structural context
(binary_expression) @expression

; Specific highlighting for arithmetic expressions
(additive_expression) @expression.arithmetic
(multiplicative_expression) @expression.arithmetic

; ──────────────────────────────────────────────────────────────────────────
; Object and Array Literals
; ──────────────────────────────────────────────────────────────────────────

; Object literals
(object) @constructor

; Array literals
(array) @constructor


; ──────────────────────────────────────────────────────────────────────────
; Mini-notation tagging and booleans (Phase 2)
; Seed: ^(s|sound|n|note|scale|chord|arp|gain|speed|pan|cutoff|lpf|hpf|hpq|delay|rev|stack|cat)$
; ──────────────────────────────────────────────────────────────────────────

; Booleans (identifiers 'true'/'false')
((identifier) @boolean
  (#match? @boolean "^(true|false)$"))

; Strings inside pattern-bearing function calls
((function_call
  (identifier) @fname
  (_ (string) @string.special))
  (#any-of? @fname "s" "sound" "n" "note" "scale" "chord" "arp" "gain" "speed" "pan" "cutoff" "lpf" "hpf" "hpq" "delay" "rev" "stack" "cat"))

; Strings inside pattern-bearing method calls
((method_call
  (identifier) @mname
  (_ (string) @string.special))
  (#any-of? @mname "s" "sound" "n" "note" "scale" "chord" "arp" "gain" "speed" "pan" "cutoff" "lpf" "hpf" "hpq" "delay" "rev" "stack" "cat"))

; Fallback: any remaining identifiers as variables; BEGIN: AUTO-GENERATED DOMAIN CAPTURES
; Domain-specific identifiers from Strudel LS builtins.json
; This block is auto-generated. Do not edit by hand.
((function_call
  (identifier)   @function.call)
  (#any-of? @function.call "DoughVoice" "OLAProcessor" "Pattern" "_begin" "_bpenv" "_bpf" "_buffers" "_channels" "_chorus" "_coarse" "_crush" "_distort" "_duration" "_euclidRot" "_fm" "_fmenv" "_hpenv" "_hpf" "_lpenv" "_lpf" "_penv" "_sound" "absOriA" "absOriB" "absOriG" "absOriX" "absOriY" "absOriZ" "absoluteOrientationAlpha" "absoluteOrientationBeta" "absoluteOrientationGamma" "absoluteOrientationX" "absoluteOrientationY" "absoluteOrientationZ" "accX" "accY" "accZ" "accelerate" "accelerationX" "accelerationY" "accelerationZ" "add" "addVoicings" "adsr" "aliasBank" "allTransforms" "almostAlways" "almostNever" "always" "amp" "appBoth" "appLeft" "appRight" "appWhole" "apply" "applyGradualLowpass" "applyHannWindow" "applyN" "arp" "arpWith" "arrange" "as" "asym" "att" "attack" "bandf" "bandq" "bank" "bbexpr" "bbst" "beat" "begin" "berlin" "binary" "binaryN" "bite" "bp" "bpa" "bpattack" "bpd")
  (#set! "priority" 120))

((function_call
  (identifier)   @function.call)
  (#any-of? @function.call "bpdecay" "bpe" "bpenv" "bpf" "bpq" "bpr" "bprelease" "bps" "bpsustain" "brak" "brand" "brandBy" "bypass" "byteBeatExpression" "byteBeatStartTime" "cat" "ccn" "ccv" "ceil" "ch" "channel" "channels" "chebyshev" "choose" "choose2" "chooseCycles" "chooseInWith" "chooseWith" "chop" "chorus" "chunk" "chunkBack" "chunkBackInto" "chunkInto" "chunkback" "chunkbackinto" "chunkinto" "chyx" "clip" "coarse" "color" "colour" "compress" "compressSpan" "compressor" "compressspan" "computeMagnitudes" "contract" "control" "cosine" "cosine2" "cpm" "crossfade" "crush" "csoundm" "ctf" "cubic" "cut" "cutoff" "dec" "decay" "defaultmidimap" "defragmentHaps" "degrade" "degradeBy" "delay" "delayfb" "delayfeedback" "delayspeed" "delaysync" "delayt" "density" "det" "detune" "dfb" "diode" "discreteOnly" "dist" "distort" "distorttype")
  (#set! "priority" 120))

((function_call
  (identifier)   @function.call)
  (#any-of? @function.call "distortvol" "disttype" "distvol" "div" "djf" "drawLine" "drive" "drop" "dry" "dt" "duck" "duckatt" "duckattack" "duckdepth" "duckons" "duckonset" "duckorbit" "dur" "duration" "each" "early" "echo" "echoWith" "echowith" "eish" "end" "euclid" "euclidLegato" "euclidLegatoRot" "euclidRot" "euclidish" "every" "expand" "extend" "fanchor" "fast" "fastChunk" "fastGap" "fastcat" "fastchunk" "fastgap" "filter" "filterHaps" "filterValues" "filterWhen" "findPeaks" "firstCycle" "firstCycleValues" "firstOf" "fit" "floor" "fm" "fmap" "fmattack" "fmdecay" "fmenv" "fmh" "fmi" "fmrelease" "fmsustain" "fmwave" "focus" "focusSpan" "focusspan" "fold" "freq" "fromBipolar" "fscope" "ftype" "gain" "gap" "generateGraph" "generateReverb" "getAllChannelData" "getFreq" "gravX" "gravY" "gravZ" "gravityX" "gravityY")
  (#set! "priority" 120))

((function_call
  (identifier)   @function.call)
  (#any-of? @function.call "gravityZ" "grow" "handleOutputBuffersToRetrieve" "hard" "hcutoff" "hp" "hpa" "hpattack" "hpd" "hpdecay" "hpe" "hpenv" "hpf" "hpq" "hpr" "hprelease" "hps" "hpsustain" "hresonance" "hsl" "hsla" "hurry" "hush" "id" "inhabit" "inhabitmod" "inside" "into" "inv" "invert" "ir" "irand" "irbegin" "iresponse" "irspeed" "isaw" "isaw2" "iter" "iterBack" "iterback" "itri" "itri2" "jux" "juxBy" "juxby" "keyDown" "label" "lastOf" "late" "layer" "legato" "leslie" "linger" "lock" "log" "logValues" "loop" "loopAt" "loopAtCps" "loopBegin" "loopEnd" "loopat" "loopatcps" "loopb" "loope" "lp" "lpa" "lpattack" "lpd" "lpdecay" "lpe" "lpenv" "lpf" "lpq" "lpr" "lprelease" "lps" "lpsustain" "lrate" "lsize")
  (#set! "priority" 120))

((function_call
  (identifier)   @function.call)
  (#any-of? @function.call "markcss" "mask" "midi" "midi2note" "midibend" "midichan" "midicmd" "midimaps" "midin" "midiport" "miditouch" "morph" "mousex" "mousey" "mul" "n" "never" "noise" "note" "nrpnn" "nrpv" "octave" "off" "often" "onTriggerTime" "onsetsOnly" "orbit" "oriA" "oriB" "oriG" "oriX" "oriY" "oriZ" "orientationAlpha" "orientationBeta" "orientationGamma" "orientationX" "orientationY" "orientationZ" "osc" "out" "outside" "pace" "palindrome" "pan" "panchor" "patt" "pattack" "pcurve" "pdec" "pdecay" "penv" "perlin" "ph" "phasdp" "phaser" "phasercenter" "phaserdepth" "phasersweep" "phc" "phd" "phs" "pianoroll" "pick" "pickF" "pickOut" "pickReset" "pickRestart" "pickSqueeze" "pickmod" "pickmodF" "pickmodOut" "pickmodReset" "pickmodRestart" "pickmodSqueeze" "pitchwheel" "ply" "plyForEach" "plyWith" "plyforeach")
  (#set! "priority" 120))

((function_call
  (identifier)   @function.call)
  (#any-of? @function.call "plywith" "pm" "polymeter" "polyrhythm" "postgain" "pr" "prel" "prelease" "prepareInputBuffersToSend" "press" "pressBy" "progNum" "psustain" "punchcard" "pure" "pw" "pwrate" "pwsweep" "queryArc" "rand" "rand2" "randcat" "randomSample" "range" "range2" "rangex" "rarely" "ratio" "rdim" "readInputs" "reallocateChannelsIfNeeded" "ref" "register" "rel" "release" "removeUndefineds" "repeatCycles" "reset" "resonance" "restart" "rev" "rfade" "rib" "ribbon" "rlp" "room" "roomdim" "roomfade" "roomlp" "roomsize" "rootNotes" "rotA" "rotB" "rotG" "rotX" "rotY" "rotZ" "rotationAlpha" "rotationBeta" "rotationGamma" "rotationX" "rotationY" "rotationZ" "round" "rsize" "run" "s" "samples" "saw" "saw2" "scale" "scaleTrans" "scaleTranspose" "scope" "scramble" "scrub" "seg" "segment" "seq" "seqPLoop")
  (#set! "priority" 120))

((function_call
  (identifier)   @function.call)
  (#any-of? @function.call "sequence" "sequenceP" "setContext" "setcpm" "shape" "shiftInputBuffers" "shiftOutputBuffers" "shiftPeaks" "showFirstCycle" "shrink" "shuffle" "silence" "sine" "sine2" "sinefold" "size" "slice" "slider" "slow" "slowChunk" "slowcat" "slowcatPrime" "slowchunk" "soft" "someCycles" "someCyclesBy" "sometimes" "sometimesBy" "sortHapsByPart" "sound" "soundAlias" "source" "sparsity" "spectrum" "speed" "spiral" "splice" "splitQueries" "spread" "square" "square2" "squeeze" "squiz" "src" "stack" "stepalt" "stepcat" "strans" "stretch" "striate" "stripContext" "struct" "stut" "stutWith" "stutwith" "sub" "superimpose" "sus" "sustain" "swing" "swingBy" "sysex" "sysexdata" "sysexid" "sz" "tables" "tag" "take" "time" "timeCat" "timecat" "toBipolar" "tour" "trans" "transpose" "trem" "tremdepth" "tremolo" "tremolodepth" "tremolophase")
  (#set! "priority" 120))

((function_call
  (identifier)   @function.call)
  (#any-of? @function.call "tremoloshape" "tremoloskew" "tremolosync" "tremphase" "tremshape" "tremskew" "tremsync" "tri" "tri2" "tscope" "undegrade" "undegradeBy" "unison" "unit" "v" "velocity" "vib" "vibmod" "vibrato" "vmod" "voicing" "voicings" "vowel" "warp" "warpatt" "warpattack" "warpdc" "warpdec" "warpdecay" "warpdepth" "warpenv" "warpmode" "warprate" "warprel" "warprelease" "warpshape" "warpskew" "warpsus" "warpsustain" "warpsync" "wavetablePhaseRand" "wavetablePosition" "wavetableWarp" "wavetableWarpMode" "wchoose" "wchooseCycles" "when" "whenKey" "withContext" "withHap" "withHapSpan" "withHapTime" "withHaps" "withLoc" "withQuerySpan" "withQueryTime" "withValue" "within" "wordfall" "wrandcat" "writeOutputs" "wt" "wtatt" "wtattack" "wtdc" "wtdec" "wtdecay" "wtdepth" "wtenv" "wtphaserand" "wtrate" "wtrel" "wtrelease" "wtshape" "wtskew" "wtsus" "wtsustain" "wtsync" "xfade" "zip")
  (#set! "priority" 120))

((function_call
  (identifier)   @function.call)
  (#any-of? @function.call "zoom" "zoomArc" "zoomarc")
  (#set! "priority" 120))
((method_call
  (identifier)   @method)
  (#any-of? @method "DoughVoice" "OLAProcessor" "Pattern" "_begin" "_bpenv" "_bpf" "_buffers" "_channels" "_chorus" "_coarse" "_crush" "_distort" "_duration" "_euclidRot" "_fm" "_fmenv" "_hpenv" "_hpf" "_lpenv" "_lpf" "_penv" "_sound" "absOriA" "absOriB" "absOriG" "absOriX" "absOriY" "absOriZ" "absoluteOrientationAlpha" "absoluteOrientationBeta" "absoluteOrientationGamma" "absoluteOrientationX" "absoluteOrientationY" "absoluteOrientationZ" "accX" "accY" "accZ" "accelerate" "accelerationX" "accelerationY" "accelerationZ" "add" "addVoicings" "adsr" "aliasBank" "allTransforms" "almostAlways" "almostNever" "always" "amp" "appBoth" "appLeft" "appRight" "appWhole" "apply" "applyGradualLowpass" "applyHannWindow" "applyN" "arp" "arpWith" "arrange" "as" "asym" "att" "attack" "bandf" "bandq" "bank" "bbexpr" "bbst" "beat" "begin" "berlin" "binary" "binaryN" "bite" "bp" "bpa" "bpattack" "bpd")
  (#set! "priority" 120))

((method_call
  (identifier)   @method)
  (#any-of? @method "bpdecay" "bpe" "bpenv" "bpf" "bpq" "bpr" "bprelease" "bps" "bpsustain" "brak" "brand" "brandBy" "bypass" "byteBeatExpression" "byteBeatStartTime" "cat" "ccn" "ccv" "ceil" "ch" "channel" "channels" "chebyshev" "choose" "choose2" "chooseCycles" "chooseInWith" "chooseWith" "chop" "chorus" "chunk" "chunkBack" "chunkBackInto" "chunkInto" "chunkback" "chunkbackinto" "chunkinto" "chyx" "clip" "coarse" "color" "colour" "compress" "compressSpan" "compressor" "compressspan" "computeMagnitudes" "contract" "control" "cosine" "cosine2" "cpm" "crossfade" "crush" "csoundm" "ctf" "cubic" "cut" "cutoff" "dec" "decay" "defaultmidimap" "defragmentHaps" "degrade" "degradeBy" "delay" "delayfb" "delayfeedback" "delayspeed" "delaysync" "delayt" "density" "det" "detune" "dfb" "diode" "discreteOnly" "dist" "distort" "distorttype")
  (#set! "priority" 120))

((method_call
  (identifier)   @method)
  (#any-of? @method "distortvol" "disttype" "distvol" "div" "djf" "drawLine" "drive" "drop" "dry" "dt" "duck" "duckatt" "duckattack" "duckdepth" "duckons" "duckonset" "duckorbit" "dur" "duration" "each" "early" "echo" "echoWith" "echowith" "eish" "end" "euclid" "euclidLegato" "euclidLegatoRot" "euclidRot" "euclidish" "every" "expand" "extend" "fanchor" "fast" "fastChunk" "fastGap" "fastcat" "fastchunk" "fastgap" "filter" "filterHaps" "filterValues" "filterWhen" "findPeaks" "firstCycle" "firstCycleValues" "firstOf" "fit" "floor" "fm" "fmap" "fmattack" "fmdecay" "fmenv" "fmh" "fmi" "fmrelease" "fmsustain" "fmwave" "focus" "focusSpan" "focusspan" "fold" "freq" "fromBipolar" "fscope" "ftype" "gain" "gap" "generateGraph" "generateReverb" "getAllChannelData" "getFreq" "gravX" "gravY" "gravZ" "gravityX" "gravityY")
  (#set! "priority" 120))

((method_call
  (identifier)   @method)
  (#any-of? @method "gravityZ" "grow" "handleOutputBuffersToRetrieve" "hard" "hcutoff" "hp" "hpa" "hpattack" "hpd" "hpdecay" "hpe" "hpenv" "hpf" "hpq" "hpr" "hprelease" "hps" "hpsustain" "hresonance" "hsl" "hsla" "hurry" "hush" "id" "inhabit" "inhabitmod" "inside" "into" "inv" "invert" "ir" "irand" "irbegin" "iresponse" "irspeed" "isaw" "isaw2" "iter" "iterBack" "iterback" "itri" "itri2" "jux" "juxBy" "juxby" "keyDown" "label" "lastOf" "late" "layer" "legato" "leslie" "linger" "lock" "log" "logValues" "loop" "loopAt" "loopAtCps" "loopBegin" "loopEnd" "loopat" "loopatcps" "loopb" "loope" "lp" "lpa" "lpattack" "lpd" "lpdecay" "lpe" "lpenv" "lpf" "lpq" "lpr" "lprelease" "lps" "lpsustain" "lrate" "lsize")
  (#set! "priority" 120))

((method_call
  (identifier)   @method)
  (#any-of? @method "markcss" "mask" "midi" "midi2note" "midibend" "midichan" "midicmd" "midimaps" "midin" "midiport" "miditouch" "morph" "mousex" "mousey" "mul" "n" "never" "noise" "note" "nrpnn" "nrpv" "octave" "off" "often" "onTriggerTime" "onsetsOnly" "orbit" "oriA" "oriB" "oriG" "oriX" "oriY" "oriZ" "orientationAlpha" "orientationBeta" "orientationGamma" "orientationX" "orientationY" "orientationZ" "osc" "out" "outside" "pace" "palindrome" "pan" "panchor" "patt" "pattack" "pcurve" "pdec" "pdecay" "penv" "perlin" "ph" "phasdp" "phaser" "phasercenter" "phaserdepth" "phasersweep" "phc" "phd" "phs" "pianoroll" "pick" "pickF" "pickOut" "pickReset" "pickRestart" "pickSqueeze" "pickmod" "pickmodF" "pickmodOut" "pickmodReset" "pickmodRestart" "pickmodSqueeze" "pitchwheel" "ply" "plyForEach" "plyWith" "plyforeach")
  (#set! "priority" 120))

((method_call
  (identifier)   @method)
  (#any-of? @method "plywith" "pm" "polymeter" "polyrhythm" "postgain" "pr" "prel" "prelease" "prepareInputBuffersToSend" "press" "pressBy" "progNum" "psustain" "punchcard" "pure" "pw" "pwrate" "pwsweep" "queryArc" "rand" "rand2" "randcat" "randomSample" "range" "range2" "rangex" "rarely" "ratio" "rdim" "readInputs" "reallocateChannelsIfNeeded" "ref" "register" "rel" "release" "removeUndefineds" "repeatCycles" "reset" "resonance" "restart" "rev" "rfade" "rib" "ribbon" "rlp" "room" "roomdim" "roomfade" "roomlp" "roomsize" "rootNotes" "rotA" "rotB" "rotG" "rotX" "rotY" "rotZ" "rotationAlpha" "rotationBeta" "rotationGamma" "rotationX" "rotationY" "rotationZ" "round" "rsize" "run" "s" "samples" "saw" "saw2" "scale" "scaleTrans" "scaleTranspose" "scope" "scramble" "scrub" "seg" "segment" "seq" "seqPLoop")
  (#set! "priority" 120))

((method_call
  (identifier)   @method)
  (#any-of? @method "sequence" "sequenceP" "setContext" "setcpm" "shape" "shiftInputBuffers" "shiftOutputBuffers" "shiftPeaks" "showFirstCycle" "shrink" "shuffle" "silence" "sine" "sine2" "sinefold" "size" "slice" "slider" "slow" "slowChunk" "slowcat" "slowcatPrime" "slowchunk" "soft" "someCycles" "someCyclesBy" "sometimes" "sometimesBy" "sortHapsByPart" "sound" "soundAlias" "source" "sparsity" "spectrum" "speed" "spiral" "splice" "splitQueries" "spread" "square" "square2" "squeeze" "squiz" "src" "stack" "stepalt" "stepcat" "strans" "stretch" "striate" "stripContext" "struct" "stut" "stutWith" "stutwith" "sub" "superimpose" "sus" "sustain" "swing" "swingBy" "sysex" "sysexdata" "sysexid" "sz" "tables" "tag" "take" "time" "timeCat" "timecat" "toBipolar" "tour" "trans" "transpose" "trem" "tremdepth" "tremolo" "tremolodepth" "tremolophase")
  (#set! "priority" 120))

((method_call
  (identifier)   @method)
  (#any-of? @method "tremoloshape" "tremoloskew" "tremolosync" "tremphase" "tremshape" "tremskew" "tremsync" "tri" "tri2" "tscope" "undegrade" "undegradeBy" "unison" "unit" "v" "velocity" "vib" "vibmod" "vibrato" "vmod" "voicing" "voicings" "vowel" "warp" "warpatt" "warpattack" "warpdc" "warpdec" "warpdecay" "warpdepth" "warpenv" "warpmode" "warprate" "warprel" "warprelease" "warpshape" "warpskew" "warpsus" "warpsustain" "warpsync" "wavetablePhaseRand" "wavetablePosition" "wavetableWarp" "wavetableWarpMode" "wchoose" "wchooseCycles" "when" "whenKey" "withContext" "withHap" "withHapSpan" "withHapTime" "withHaps" "withLoc" "withQuerySpan" "withQueryTime" "withValue" "within" "wordfall" "wrandcat" "writeOutputs" "wt" "wtatt" "wtattack" "wtdc" "wtdec" "wtdecay" "wtdepth" "wtenv" "wtphaserand" "wtrate" "wtrel" "wtrelease" "wtshape" "wtskew" "wtsus" "wtsustain" "wtsync" "xfade" "zip")
  (#set! "priority" 120))

((method_call
  (identifier)   @method)
  (#any-of? @method "zoom" "zoomArc" "zoomarc")
  (#set! "priority" 120))
((method_call
  (identifier)   @function.method)
  (#any-of? @function.method "DoughVoice" "OLAProcessor" "Pattern" "_begin" "_bpenv" "_bpf" "_buffers" "_channels" "_chorus" "_coarse" "_crush" "_distort" "_duration" "_euclidRot" "_fm" "_fmenv" "_hpenv" "_hpf" "_lpenv" "_lpf" "_penv" "_sound" "absOriA" "absOriB" "absOriG" "absOriX" "absOriY" "absOriZ" "absoluteOrientationAlpha" "absoluteOrientationBeta" "absoluteOrientationGamma" "absoluteOrientationX" "absoluteOrientationY" "absoluteOrientationZ" "accX" "accY" "accZ" "accelerate" "accelerationX" "accelerationY" "accelerationZ" "add" "addVoicings" "adsr" "aliasBank" "allTransforms" "almostAlways" "almostNever" "always" "amp" "appBoth" "appLeft" "appRight" "appWhole" "apply" "applyGradualLowpass" "applyHannWindow" "applyN" "arp" "arpWith" "arrange" "as" "asym" "att" "attack" "bandf" "bandq" "bank" "bbexpr" "bbst" "beat" "begin" "berlin" "binary" "binaryN" "bite" "bp" "bpa" "bpattack" "bpd")
  (#set! "priority" 119))

((method_call
  (identifier)   @function.method)
  (#any-of? @function.method "bpdecay" "bpe" "bpenv" "bpf" "bpq" "bpr" "bprelease" "bps" "bpsustain" "brak" "brand" "brandBy" "bypass" "byteBeatExpression" "byteBeatStartTime" "cat" "ccn" "ccv" "ceil" "ch" "channel" "channels" "chebyshev" "choose" "choose2" "chooseCycles" "chooseInWith" "chooseWith" "chop" "chorus" "chunk" "chunkBack" "chunkBackInto" "chunkInto" "chunkback" "chunkbackinto" "chunkinto" "chyx" "clip" "coarse" "color" "colour" "compress" "compressSpan" "compressor" "compressspan" "computeMagnitudes" "contract" "control" "cosine" "cosine2" "cpm" "crossfade" "crush" "csoundm" "ctf" "cubic" "cut" "cutoff" "dec" "decay" "defaultmidimap" "defragmentHaps" "degrade" "degradeBy" "delay" "delayfb" "delayfeedback" "delayspeed" "delaysync" "delayt" "density" "det" "detune" "dfb" "diode" "discreteOnly" "dist" "distort" "distorttype")
  (#set! "priority" 119))

((method_call
  (identifier)   @function.method)
  (#any-of? @function.method "distortvol" "disttype" "distvol" "div" "djf" "drawLine" "drive" "drop" "dry" "dt" "duck" "duckatt" "duckattack" "duckdepth" "duckons" "duckonset" "duckorbit" "dur" "duration" "each" "early" "echo" "echoWith" "echowith" "eish" "end" "euclid" "euclidLegato" "euclidLegatoRot" "euclidRot" "euclidish" "every" "expand" "extend" "fanchor" "fast" "fastChunk" "fastGap" "fastcat" "fastchunk" "fastgap" "filter" "filterHaps" "filterValues" "filterWhen" "findPeaks" "firstCycle" "firstCycleValues" "firstOf" "fit" "floor" "fm" "fmap" "fmattack" "fmdecay" "fmenv" "fmh" "fmi" "fmrelease" "fmsustain" "fmwave" "focus" "focusSpan" "focusspan" "fold" "freq" "fromBipolar" "fscope" "ftype" "gain" "gap" "generateGraph" "generateReverb" "getAllChannelData" "getFreq" "gravX" "gravY" "gravZ" "gravityX" "gravityY")
  (#set! "priority" 119))

((method_call
  (identifier)   @function.method)
  (#any-of? @function.method "gravityZ" "grow" "handleOutputBuffersToRetrieve" "hard" "hcutoff" "hp" "hpa" "hpattack" "hpd" "hpdecay" "hpe" "hpenv" "hpf" "hpq" "hpr" "hprelease" "hps" "hpsustain" "hresonance" "hsl" "hsla" "hurry" "hush" "id" "inhabit" "inhabitmod" "inside" "into" "inv" "invert" "ir" "irand" "irbegin" "iresponse" "irspeed" "isaw" "isaw2" "iter" "iterBack" "iterback" "itri" "itri2" "jux" "juxBy" "juxby" "keyDown" "label" "lastOf" "late" "layer" "legato" "leslie" "linger" "lock" "log" "logValues" "loop" "loopAt" "loopAtCps" "loopBegin" "loopEnd" "loopat" "loopatcps" "loopb" "loope" "lp" "lpa" "lpattack" "lpd" "lpdecay" "lpe" "lpenv" "lpf" "lpq" "lpr" "lprelease" "lps" "lpsustain" "lrate" "lsize")
  (#set! "priority" 119))

((method_call
  (identifier)   @function.method)
  (#any-of? @function.method "markcss" "mask" "midi" "midi2note" "midibend" "midichan" "midicmd" "midimaps" "midin" "midiport" "miditouch" "morph" "mousex" "mousey" "mul" "n" "never" "noise" "note" "nrpnn" "nrpv" "octave" "off" "often" "onTriggerTime" "onsetsOnly" "orbit" "oriA" "oriB" "oriG" "oriX" "oriY" "oriZ" "orientationAlpha" "orientationBeta" "orientationGamma" "orientationX" "orientationY" "orientationZ" "osc" "out" "outside" "pace" "palindrome" "pan" "panchor" "patt" "pattack" "pcurve" "pdec" "pdecay" "penv" "perlin" "ph" "phasdp" "phaser" "phasercenter" "phaserdepth" "phasersweep" "phc" "phd" "phs" "pianoroll" "pick" "pickF" "pickOut" "pickReset" "pickRestart" "pickSqueeze" "pickmod" "pickmodF" "pickmodOut" "pickmodReset" "pickmodRestart" "pickmodSqueeze" "pitchwheel" "ply" "plyForEach" "plyWith" "plyforeach")
  (#set! "priority" 119))

((method_call
  (identifier)   @function.method)
  (#any-of? @function.method "plywith" "pm" "polymeter" "polyrhythm" "postgain" "pr" "prel" "prelease" "prepareInputBuffersToSend" "press" "pressBy" "progNum" "psustain" "punchcard" "pure" "pw" "pwrate" "pwsweep" "queryArc" "rand" "rand2" "randcat" "randomSample" "range" "range2" "rangex" "rarely" "ratio" "rdim" "readInputs" "reallocateChannelsIfNeeded" "ref" "register" "rel" "release" "removeUndefineds" "repeatCycles" "reset" "resonance" "restart" "rev" "rfade" "rib" "ribbon" "rlp" "room" "roomdim" "roomfade" "roomlp" "roomsize" "rootNotes" "rotA" "rotB" "rotG" "rotX" "rotY" "rotZ" "rotationAlpha" "rotationBeta" "rotationGamma" "rotationX" "rotationY" "rotationZ" "round" "rsize" "run" "s" "samples" "saw" "saw2" "scale" "scaleTrans" "scaleTranspose" "scope" "scramble" "scrub" "seg" "segment" "seq" "seqPLoop")
  (#set! "priority" 119))

((method_call
  (identifier)   @function.method)
  (#any-of? @function.method "sequence" "sequenceP" "setContext" "setcpm" "shape" "shiftInputBuffers" "shiftOutputBuffers" "shiftPeaks" "showFirstCycle" "shrink" "shuffle" "silence" "sine" "sine2" "sinefold" "size" "slice" "slider" "slow" "slowChunk" "slowcat" "slowcatPrime" "slowchunk" "soft" "someCycles" "someCyclesBy" "sometimes" "sometimesBy" "sortHapsByPart" "sound" "soundAlias" "source" "sparsity" "spectrum" "speed" "spiral" "splice" "splitQueries" "spread" "square" "square2" "squeeze" "squiz" "src" "stack" "stepalt" "stepcat" "strans" "stretch" "striate" "stripContext" "struct" "stut" "stutWith" "stutwith" "sub" "superimpose" "sus" "sustain" "swing" "swingBy" "sysex" "sysexdata" "sysexid" "sz" "tables" "tag" "take" "time" "timeCat" "timecat" "toBipolar" "tour" "trans" "transpose" "trem" "tremdepth" "tremolo" "tremolodepth" "tremolophase")
  (#set! "priority" 119))

((method_call
  (identifier)   @function.method)
  (#any-of? @function.method "tremoloshape" "tremoloskew" "tremolosync" "tremphase" "tremshape" "tremskew" "tremsync" "tri" "tri2" "tscope" "undegrade" "undegradeBy" "unison" "unit" "v" "velocity" "vib" "vibmod" "vibrato" "vmod" "voicing" "voicings" "vowel" "warp" "warpatt" "warpattack" "warpdc" "warpdec" "warpdecay" "warpdepth" "warpenv" "warpmode" "warprate" "warprel" "warprelease" "warpshape" "warpskew" "warpsus" "warpsustain" "warpsync" "wavetablePhaseRand" "wavetablePosition" "wavetableWarp" "wavetableWarpMode" "wchoose" "wchooseCycles" "when" "whenKey" "withContext" "withHap" "withHapSpan" "withHapTime" "withHaps" "withLoc" "withQuerySpan" "withQueryTime" "withValue" "within" "wordfall" "wrandcat" "writeOutputs" "wt" "wtatt" "wtattack" "wtdc" "wtdec" "wtdecay" "wtdepth" "wtenv" "wtphaserand" "wtrate" "wtrel" "wtrelease" "wtshape" "wtskew" "wtsus" "wtsustain" "wtsync" "xfade" "zip")
  (#set! "priority" 119))

((method_call
  (identifier)   @function.method)
  (#any-of? @function.method "zoom" "zoomArc" "zoomarc")
  (#set! "priority" 119))
; END: AUTO-GENERATED DOMAIN CAPTURES


(identifier) @variable
