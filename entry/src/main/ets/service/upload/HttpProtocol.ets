import { buffer } from '@kit.ArkTS'

export type HttpMethod = 'POST' | 'GET'

const CRLF = '\r\n'

export class HttpProtocol {
  protocol: string = 'HTTP/1.1'
  method: HttpMethod = 'GET'
  url: string = '/'
  hostname: string
  port: number
  isKeepAlive: boolean = false
  headers: Map<string, string> = new Map()
  content: string | ArrayBuffer = ''

  constructor(hostname: string, port: number) {
    this.hostname = hostname
    this.port = port
  }

  setContentType(contentType: string) {
    this.addHeader('Content-Type', contentType)
  }

  setContentLength(length: number) {
    this.addHeader('Content-Length', `${length}`)
  }

  addHeader(name: string, value: string) {
    if (!name && name.length > 0) {
      throw Error('The request header cannot be empty')
    }
    this.headers.set(this.getHeadNameReadability(name), value)
  }

  setKeepAlive(isKeepAlive: boolean) {
    this.isKeepAlive = isKeepAlive
  }

  toMessage(): ArrayBuffer {
    this.headers.set('Host', `${this.hostname}:${this.port}`)
    if (this.isKeepAlive) {
      this.addHeader('Connection', this.headers.get('Connection') || 'keep-alive')
    }
    this.addHeader('Accept', this.headers.get('Accept') || '*/*')
    this.addHeader('Content-Length', this.headers.get('Content-Length') || `${buffer.byteLength(this.content)}`)

    let message = `${this.method} ${this.url} ${this.protocol}${CRLF}`
    for (const header of this.headers.entries()) {
      message += `${header[0]}: ${header[1]}\n`
    }
    message += CRLF

    if (typeof this.content === 'string') {
      const result: buffer.Buffer = buffer.allocUninitializedFromPool(message.length + this.content.length)
      result.write(message)
      result.write(this.content, message.length)
      return result.buffer
    } else {
      const buf = buffer.from(this.content)
      const result: buffer.Buffer = buffer.allocUninitializedFromPool(message.length + buf.length)
      result.write(message)
      buf.copy(result, message.length, 0, buf.length)
      return result.buffer
    }
  }

  getHeadNameReadability(headName: string): string {
    const array = headName.split('-')
    const names: string[] = []
    for (const element of array) {
      if (element.length > 0) {
        names.push(`${element.charAt(0).toUpperCase()}${element.substring(1)}`)
      }
    }
    if (names.length > 0) {
      return names.join('-')
    }
    return ''
  }
}