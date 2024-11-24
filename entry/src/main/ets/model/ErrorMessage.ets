export class ErrorMessage {
  message?: string
  code?: number | undefined

  constructor(message?: string, code?: number | undefined) {
    this.message = message
    this.code = code
  }
}