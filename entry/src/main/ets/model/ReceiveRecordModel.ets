export class ReceiveRecordModel {
  id: number = NaN
  fileId: string = ''
  fileName: string = ''
  fileType: string = ''
  size: number = 0
  filePath: string = ''
  sender: string = ''
  sendAt: number = 0

  isSandbox(): boolean {
    if (this.filePath && this.filePath.startsWith('/data/storage')) {
      return true
    }
    return false
  }
}