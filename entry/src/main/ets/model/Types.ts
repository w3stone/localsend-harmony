export interface FileInfoModel {
  id: string,
  fileName: string
  size: number
  fileType: string
  sha256?: string
  preview?: string
  metadata: FileMetadata
}

export interface FileMetadata {
  modified: string
  accessed: string
}

export interface FileInfoKeyMap {
  [key: string]: FileInfoModel;
}