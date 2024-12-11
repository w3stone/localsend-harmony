import { FileTransferStatus } from ".";

@Observed
export class FileTransferInfo {
  status: FileTransferStatus = FileTransferStatus.QUEUE
  progress: number = 0
  filePath?: string
  error?: object | undefined | null
}