export const exampleList = [
  ['arduino', '.ino'],
  ['bash', '.sh'],
  ['awk', '.awk'],
  ['c', '.c'],
  // ['clojure', '.clj'], // Incompatible language version 9. Compatibility range 13 through 15.
  ['cpp', '.cpp'],
  ['c-sharp', '.cs'],
  ['css', '.css'],
  // ['csv', '.csv'],
  // ['d', '.d'],
  ['dart', '.dart'],
  ['diff', '.diff'],
  ['elisp', '.el'],
  ['elixir', '.ex'],
  ['fortran', '.f90'],
  ['forth', '.fs'],
  ['go', '.go'],
  ['haskell', '.hs'],
  ['html', '.html'],
  ['haxe', '.hx'],
  ['janet', '.janet'],
  ['java', '.java'],
  ['julia', '.jl'],
  ['javascript', '.js'],
  ['json', '.json'],
  ['kotlin', '.kt'],
  // ['latex', '.tex'],
  ['lean', '.lean'],
  ['commonlisp', '.lisp'],
  ['lilypond', '.ly'],
  ['lua', '.lua'],
  ['matlab', '.m'],
  ['make', '.make'],
  ['markdown', '.md'],
  ['ocaml', '.ml'],
  ['nim', '.nim'],
  ['nix', '.nix'],
  ['odin', '.odin'],
  // ['pascal', '.pas'],
  ['php', '.php'],
  // ['perl', '.pl'],
  ['prolog', '.prolog'],
  // ['psv', '.psv'],
  ['pug', '.pug'],
  ['python', '.py'],
  ['r', '.r'],
  ['ruby', '.rb'],
  ['racket', '.rkt'],
  ['rust', '.rs'],
  ['scala', '.scala'],
  ['scss', '.scss'],
  // ['sql', '.sql'],
  ['strudel', '.strdl'],
  // ['swift', '.swift'],
  ['uxntal', '.tal'],
  ['tcl', '.tcl'],
  ['toml', '.toml'],
  ['typescript', '.ts'],
  // ['tsv', '.tsv'],
  // ['wat', '.wat'],
  ['xml', '.xml'],
  // ['yaml', '.yaml'], // bad export type for 'tree_sitter_yaml_external_scanner_create': undefined
  ['zig', '.zig'],
]

export async function runExamples({
  getExampleFile,
  examples = exampleList,
  Parser,
  Language,
  wasmPath = '.',
  onEvent,
}) {
  await Parser.init()

  const parser = new Parser()

  for (let [lang, _code] of examples) {
    const file = _code.startsWith('.') ? `example${_code}` : undefined
    const [code, languageModule] = await Promise.all([
      file ? await getExampleFile(file) : _code,
      Language.load(`${wasmPath.replace(/\/$/, '')}/tree-sitter-${lang}.wasm`),
    ])

    onEvent && onEvent({ type: 'start', lang, code, file })

    parser.setLanguage(languageModule)

    const tree = parser.parse(code)

    let result
    const generator = walkGenerator(tree)
    while ((result = generator.next()) && !result.done) {
      const node = result.value
      const nodeData = getNodeData(node)
      onEvent && onEvent({ type: 'node', node: nodeData, lang })
    }

    onEvent && onEvent({ type: 'end', lang })
  }
}

function* walkGenerator(tree) {
  let visitedChildren = false
  let returnValue
  const cursor = tree.walk()

  while (true) {
    if (!visitedChildren) {
      returnValue = yield cursor.currentNode

      // TODO: Optionally use return value to control flow, such as reset loop

      if (!cursor.gotoFirstChild()) {
        visitedChildren = true
      }
    } else if (cursor.gotoNextSibling()) {
      visitedChildren = false
    } else if (!cursor.gotoParent()) {
      break
    }
  }
}

/**
 * Async walk
 */
async function walkAsync(tree, asyncCallback) {
  let result
  let returnValue
  const generator = walkGenerator(tree)
  while ((result = generator.next(returnValue)) && !result.done) {
    returnValue = await asyncCallback(result.value)
  }
}

/**
 * Synchronous walk
 */
function walk(tree, callback) {
  let visitedChildren = false
  const cursor = tree.walk()
  while (true) {
    if (!visitedChildren) {
      const node = cursor.currentNode
      callback(node)
      if (!cursor.gotoFirstChild()) {
        visitedChildren = true
      }
    } else if (cursor.gotoNextSibling()) {
      visitedChildren = false
    } else if (!cursor.gotoParent()) {
      break
    }
  }
}

function getNodeData(node) {
  return {
    id: node.id,
    type: node.type,
    start: node.startPosition,
    end: node.endPosition,
    // For many nodes, text is redundant (same as type) or unnecessary
    text: node.text,
    parent: node.parent?.id,
  }
}
