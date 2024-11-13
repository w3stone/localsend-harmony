/**
 * 接受其他设备发送文件请求后返回的结果
 */
export class AcceptReceiveModel {
  sessionId: string
  files: Map<string, string>

  constructor(sessionId: string, files: Map<string, string>) {
    this.sessionId = sessionId
    this.files = files
  }
}