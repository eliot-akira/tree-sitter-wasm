import fs from 'node:fs/promises'
import {
  Edit,
  Language,
  // type Node,
  Parser,
  Query,
  // type Tree,
  TreeCursor,
} from './docs/web-tree-sitter'
import type { Node, Tree } from './docs/web-tree-sitter.d.ts'
import { runExamples } from './docs/example.js'
import path from 'node:path'

runExamples({
  Language,
  Parser,
  wasmPath: './docs',
  async getExampleFile(file: string) {
    return await fs.readFile(
      path.join(__dirname, 'docs', 'examples', file),
      'utf8'
    )
  },
  onEvent(e) {
    switch (e.type) {
      case 'start':
        console.log('==========')
        console.log('Language:', e.lang)
        console.log('Code:')
        console.log(e.code)
        console.log('==========')

        break
      case 'node':
        const showText = ['number', 'identifier'].indexOf(e.node.type) >= 0
        console.log(e.node.type, showText ? e.node.text : '')
        break
    }
  },
})

function getAllNodes(tree: Tree): Node[] {
  const result: Node[] = []
  let visitedChildren = false
  const cursor = tree.walk()

  while (true) {
    if (!visitedChildren) {
      const node = cursor.currentNode
      result.push(node)
      if (!cursor.gotoFirstChild()) {
        visitedChildren = true
      }
    } else if (cursor.gotoNextSibling()) {
      visitedChildren = false
    } else if (!cursor.gotoParent()) {
      break
    }
  }
  return result
}

function getNodeData(node: Node) {
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
