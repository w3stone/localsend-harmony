import { JSON } from "@kit.ArkTS"

export class Errors {
  static getErrorMessage(e: object): string {
    if (e instanceof Error) {
      return `${JSON.stringify(e.message)}\n${(e.stack) ? e.stack : ''}`
    } else if (e) {
      return JSON.stringify(e)
    }
    return ''
  }
}