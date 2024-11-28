import { DeviceModel, FileInfoModel, StringPair } from '.'

export class TransferPageParam {
  isSent: boolean
  /**
   * 发送或接收的文件列表，为发送文件时列表中需要有filePath字段
   */
  files: FileInfoModel[]
  /**
   * 保存文件fd
   */
  fd?: number
  /**
   * 发送时必填参数，prepare-upload接口返回的sessionId
   */
  sessionId?: string
  /**
   * 发送时传接收方设备信息
   */
  target?: DeviceModel[]
  /**
   * <fileId,token> 键值对 prepare-upload接口返回的files
   */
  fileToken?: StringPair

  /**
   * 跳转文件传输界面的传参
   * @param isSent true: 发送文件 false: 接收文件
   * @param files 发送或接收的文件列表，为发送文件时列表中需要有filePath字段
   */
  constructor(isSent: boolean, files: FileInfoModel[], fd?: number) {
    this.isSent = isSent
    this.files = files
    this.fd = fd
  }
}