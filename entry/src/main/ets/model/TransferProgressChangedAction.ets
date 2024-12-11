import { FileTransferStatus } from "."

/**
 * 文件传输进度更新数据
 */
export interface TransferProgressChangedAction {
  fileId: string
  status: FileTransferStatus
  progress: number
  total: number
  speed: number //单位: 字节/s
  filePath?: string //接收文件时保存的路径
  error?: object
}