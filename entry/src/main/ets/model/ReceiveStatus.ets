import { FileInfoModel } from "."

export class ReceiveStatus {
  progress: number = 0
  total: number = 0
  files: FileInfoModel[] = []
}

export interface FileStatus extends FileInfoModel {
  progress: number
  total: number
}