import { FileTransferStatus } from "."

/**
 * 文件传输进度更新数据
 */
export interface TransferProgressChangedAction {
  status: FileTransferStatus
  progress: number
  total: number
  fileId: string
  error?: object
}