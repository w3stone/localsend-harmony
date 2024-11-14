import { AcceptReceiveModel, FileReceiveQueueModel } from '../model';
import { Keys } from '../constant';

export class FileProvider {
  private static FILE_RECEIVE_QUEUE = 'FILE_RECEIVE_QUEUE'
  private static ONE_KB: number = 1024
  private static ONE_MB: number = FileProvider.ONE_KB * 1024
  private static ONE_GB: number = FileProvider.ONE_MB * 1024

  private constructor() {
  }

  static addFileToReceiveQueue(receive: AcceptReceiveModel) {
    const model = new FileReceiveQueueModel(receive)
    const files: Map<string, FileReceiveQueueModel> = AppStorage.get(FileProvider.FILE_RECEIVE_QUEUE) || new Map()
    files.set(model.sessionId, model)
    AppStorage.setOrCreate(FileProvider.FILE_RECEIVE_QUEUE, files)
  }

  static formatBytes(bytes: number): string {
    if (bytes < 1024) {
      return `${bytes.toFixed(0)} B`
    } else if (bytes < FileProvider.ONE_MB) {
      return `${(bytes / FileProvider.ONE_KB).toFixed(2)} KB`
    } else if (bytes < FileProvider.ONE_GB) {
      return `${(bytes / FileProvider.ONE_MB).toFixed(2)} MB`
    } else {
      return `${(bytes / FileProvider.ONE_GB).toFixed(2)} GB`
    }
  }

  private static ALL_TYPES: string[] = ['all']
  private static FILE_TYPES: Map<string, string[]> = new Map()
    .set('application', ['doc', 'pdf', 'ppt', 'xls', 'zip', 'rar', '7z'])
    .set('audio', FileProvider.ALL_TYPES)
    .set('image', FileProvider.ALL_TYPES)
    .set('video', FileProvider.ALL_TYPES)
    .set('text', ['html', 'txt', 'xml', 'all'])

  static getFileIconRes(fileName: string, fileTypes: string): Resource {
    const suffixIndex = fileName.lastIndexOf('.')
    const types = fileTypes.split('/')
    let type: string = ''
    let suffix: string = ''
    let fileType: string = ''
    if (types.length >= 2) {
      type = types[0]
      fileType = types[1]
    }
    if (suffixIndex > 0) {
      suffix = fileName.substring(suffixIndex + 1)
    }
    const subTypes: string[] | undefined = FileProvider.FILE_TYPES.get(type)
    let resName = 'ic_files_unknown'
    if (subTypes) {
      const t: string | undefined = subTypes.find((item: string, index: number, obj: string[]) => {
        return (item == fileType || item == suffix || item == 'all') ? obj[index] : undefined
      })
      if (t) {
        resName = `ic_files_${type}_${t}`
      }
    }
    return $r(`app.media.${resName}`)
  }

  static setReceivingFiles(isReceiving: boolean) {
    AppStorage.setOrCreate(Keys.CURRENTLY_RECEIVING_STATUS, isReceiving)
  }

  static isReceivingFiles(): boolean {
    return AppStorage.get(Keys.CURRENTLY_RECEIVING_STATUS) || false
  }

  static getDefaultFileDir(context: Context): string {
    return context.filesDir
  }
}
