import { StringPair } from "."

/**
 * 调用prepare-upload接口返回的结果
 */
export class PrepareTransferModel {
  sessionId: string
  /**
   * Map<fileId, fileToken>
   */
  files: StringPair

  constructor(sessionId: string, files: StringPair) {
    this.sessionId = sessionId
    this.files = files
  }
}