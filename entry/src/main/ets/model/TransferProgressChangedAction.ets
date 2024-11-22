import { FileTransferStatus } from "."

/**
 * 文件传输进度更新数据
 */
export interface TransferProgressChangedAction {
  fileId: string
  status: FileTransferStatus
  progress: number
  total: number
  speed: number  //单位: 字节/s
  error?: object
}