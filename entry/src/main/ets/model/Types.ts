export interface FileInfoModel {
  id: string,
  fileName: string
  size: number
  fileType: string
  sha256?: string
  preview?: string
  metadata?: FileMetadata
  filePath?: string | undefined //仅发送时有值
  status?: number
}

export interface FileMetadata {
  modified: string | undefined
  accessed: string | undefined
}

export interface FileInfoKeyMap {
  [key: string]: FileInfoModel;
}

export interface StringPair {
  [key: string]: string
}

export interface StringNumberPair {
  [key: string]: number
}

export type DeviceType = string | 'mobile' | 'desktop' | 'web' | 'headless' | 'server'