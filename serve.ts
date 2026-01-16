import path from 'node:path'

function sanitizePath(str: string): string {
  return path.normalize(str).replace(/^(..(\/|\\|$))+/, '')
}

const port = 3000
const publicPath = './docs'

Bun.serve({
  port,
  async fetch(req) {
    let filePath = sanitizePath(new URL(req.url).pathname)
      .replace(/^\//, '') // Trim starting slash
    const fileParts = (filePath.split('/').pop() || '').split('.')
    const extension = fileParts.length > 1 ? fileParts.pop() : ''
    if (!extension) {
      filePath += `${filePath.endsWith('/') ? '' : '/'}index.html`
    }

    const file = Bun.file(`${publicPath}/${filePath}`)
    console.log(filePath, extension)
    // const fileData = await stat(filePath);
    return new Response(file)
  },
  error() {
    return new Response(null, { status: 404 })
  },
})

console.log(`Serving at http://localhost:${port}`)
