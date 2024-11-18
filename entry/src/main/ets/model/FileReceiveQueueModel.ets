import { FileInfoModel, FileTransferStatus } from '.';

export class FileReceiveQueueModel {
  otherside: string //对方别名
  remoteIp: string //对方请求IP
  session: string
  file: FileInfoModel
  fileToken: string
  status: FileTransferStatus = FileTransferStatus.QUEUE
  progress: number = 0 //已接收大小
  total: number = 0 //文件总大小

  constructor(session: string, file: FileInfoModel, fileToken: string, otherside: string, remoteIp: string) {
    this.session = session
    this.file = file
    this.fileToken = fileToken
    this.otherside = otherside
    this.total = file.size
    this.remoteIp = remoteIp
  }
}