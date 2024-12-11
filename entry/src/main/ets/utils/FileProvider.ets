import { FileInfoModel, FileReceiveQueueModel, PendingSendFile, PrepareTransferModel, PrepareUploadModel } from '../model';
import { Keys } from '../constant';
import { Errors, logger, Strings } from 'common';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';
import { buffer, util } from '@kit.ArkTS';
import { mime } from './mime';
import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Context } from '@kit.AbilityKit';

const TAG = 'FileProvider'

export class FileProvider {
  private static FILE_RECEIVE_QUEUE = 'FILE_RECEIVE_QUEUE'
  private static ONE_KB: number = 1024
  private static ONE_MB: number = FileProvider.ONE_KB * 1024
  private static ONE_GB: number = FileProvider.ONE_MB * 1024
  private static PENDING_TO_SEND_DIR = '/pending_to_send'

  private constructor() {
  }

  /**
   * 添加文件接收信息到队列中
   * @param upload 待接收文件
   * @param reception 文件接收信息 sessionID以及fileId对应的fileToken
   * @param remoteIp 请求发送文件的设备IP，用于接收文件时鉴权
   */
  static addFilesToReceiveQueue(upload: PrepareUploadModel, reception: PrepareTransferModel, remoteIp: string) {
    // files Map<fileToken,FileReceiveQueueModel>
    const queue: Map<string, FileReceiveQueueModel> = AppStorage.get(FileProvider.FILE_RECEIVE_QUEUE) || new Map()
    Object.keys(reception.files).forEach((fileId: string) => {
      const fileToken = reception.files[fileId]
      const waiting = new FileReceiveQueueModel(reception.sessionId, upload.files[fileId], fileToken, upload.info.alias, remoteIp)
      queue.set(fileToken, waiting)
    })
    AppStorage.setOrCreate(FileProvider.FILE_RECEIVE_QUEUE, queue)
    AppStorage.setOrCreate(Keys.CURRENTLY_RECEIVING_SESSION, reception.sessionId)
    logger.debug('FileProvider', `当前文件队列: ${queue.size}`)
  }

  /**
   * 清除当前文件传输队列
   */
  static clearFilesReceiveQueue() {
    AppStorage.delete(FileProvider.FILE_RECEIVE_QUEUE)
  }

  /**
   * 根据fileToken从队列中获取文件传输信息
   * @param fileToken token
   * @returns [FileReceiveQueueModel]
   */
  static getReceiveFileInfo(fileToken: string): FileReceiveQueueModel | undefined {
    const queue: Map<string, FileReceiveQueueModel> | undefined =
      AppStorage.get<Map<string, FileReceiveQueueModel>>(FileProvider.FILE_RECEIVE_QUEUE)
    if (queue != undefined) {
      return queue.get(fileToken)
    }
    return
  }

  /**
   * 文件大小可视化
   * @param bytes 字节数
   * @returns xx B,xx KB,xx MB,xx GB
   */
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

  /**
   * 根据文件名后缀和文件类型返回一个图标资源
   * @param fileName 文件名
   * @param fileTypes 文件类型 application/xxx
   * @returns
   */
  static getFileIconRes(fileName: string, fileTypes: string): Resource {
    const types = fileTypes.split('/')
    let type: string = ''
    let fileType: string = ''
    if (types.length >= 2) {
      type = types[0]
      fileType = types[1]
    }
    const suffix: string = FileProvider.getFileSuffixName(fileName)
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

  /**
   * 获取文件后缀
   * @param fileName 文件名
   * @returns
   */
  static getFileSuffixName(fileName: string): string {
    const suffixIndex = fileName.lastIndexOf('.')
    if (suffixIndex > 0) {
      return fileName.substring(suffixIndex + 1)
    }
    return ''
  }

  /**
   * 获取文件名
   * @param pathName 文件路径
   * @returns
   */
  static getFileName(pathName: string): string {
    const suffixIndex = pathName.lastIndexOf('/')
    if (suffixIndex > 0) {
      return pathName.substring(suffixIndex + 1)
    }
    return ''
  }

  /**
   * 设置当前是否正在处理文件传输
   * @param transferring true 正在传输文件
   */
  static setTransferringNow(transferring: boolean) {
    AppStorage.setOrCreate(Keys.CURRENTLY_TRANSFERRING_STATUS, transferring)
  }

  /**
   * @returns true: 正在处理文件传输请求
   */
  static isTransferringNow(): boolean {
    return AppStorage.get(Keys.CURRENTLY_TRANSFERRING_STATUS) || false
  }

  /**
   * 设置当前正在传输文件的sessionId
   * @param sessionId
   */
  static setTransferringNowSessionId(sessionId: string | undefined) {
    AppStorage.setOrCreate(Keys.CURRENTLY_RECEIVING_SESSION, sessionId)
  }

  /**
   * 获取当前正在传输文件的sessionId
   * @returns
   */
  static getTransferringNowSessionId(): string | undefined {
    return AppStorage.get(Keys.CURRENTLY_RECEIVING_SESSION)
  }

  /**
   * 清理文件传输相关缓存
   */
  static setTransferComplete() {
    FileProvider.setTransferringNow(false)
    FileProvider.setTransferringNowSessionId(undefined)
    FileProvider.clearFilesReceiveQueue()
  }

  /**
   * 文件默认缓存目录
   * @param context
   * @returns
   */
  static getDefaultFileDir(context: Context): string {
    return `${context.filesDir}/received`
  }

  /**
   * 选择文件
   * @param selectMode
   * @returns
   */
  static async selectFile(context: Context, selected: PendingSendFile[]): Promise<Array<PendingSendFile>> {
    try {
      const options = new picker.DocumentSelectOptions()
      options.maxSelectNumber = 5;
      // options.fileSuffixFilters = ['*/*']

      const uris = await new picker.DocumentViewPicker(context).select(options)
      const files: PendingSendFile[] = []
      let stat: fs.Stat
      for (const uri of uris) {
        const path = new fileUri.FileUri(uri).path
        const findIndex = selected.findIndex((file: PendingSendFile, _: number) => file.filePath === path)
        if (findIndex >= 0) {
          continue
        }
        stat = await fs.stat(path)
        files.push({
          id: util.generateRandomUUID(),
          fileName: FileProvider.getFileName(path),
          size: stat.size,
          fileType: mime.getType(path) || "",
          // metadata: {
          //   modified: (stat.mtime > 0) ? DateUtil.getFormatDate(stat.mtime).toUTCString() : undefined,
          //   accessed: (stat.atime > 0) ? DateUtil.getFormatDate(stat.atime).toUTCString() : undefined
          // },
          // filePath: path
          filePath: uri
        })
      }
      return files
    } catch (e) {
      logger.info(TAG, `select file error: ${e.message}\n${e.stack}`)
    }
    return []
  }

  static async getMedia(context: Context, selected: PendingSendFile[]): Promise<Array<PendingSendFile>> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.maxSelectNumber = 5;
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE

      const result: photoAccessHelper.PhotoSelectResult = await new photoAccessHelper.PhotoViewPicker().select(photoSelectOptions)
      const uris = result.photoUris
      const files: PendingSendFile[] = []
      let stat: fs.Stat
      for (const uri of uris) {
        // const path = new fileUri.FileUri(uri).path
        // console.info(`uri: ${uri}\npath: ${path}`)
        const newFilePath = await FileProvider.copyMediaFileToCache(context, uri)
        const findIndex = selected.findIndex((file: PendingSendFile, _: number) => file.filePath === newFilePath)
        if (findIndex >= 0) {
          continue
        }
        stat = await fs.stat(newFilePath)
        files.push({
          id: util.generateRandomUUID(),
          fileName: FileProvider.getFileName(newFilePath),
          size: stat.size,
          fileType: mime.getType(newFilePath) || "",
          // metadata: {
          //   modified: (stat.mtime > 0) ? DateUtil.getFormatDate(stat.mtime).toUTCString() : undefined,
          //   accessed: (stat.atime > 0) ? DateUtil.getFormatDate(stat.atime).toUTCString() : undefined
          // },
          filePath: newFilePath
        })
      }
      return files
    } catch (e) {
      logger.info(TAG, `select file error: ${e.message}\n${e.stack}`)
    }
    return []
  }

  private static async copyMediaFileToCache(context: Context, uri: string): Promise<string> {
    const dir: string = `${context.cacheDir}/${FileProvider.PENDING_TO_SEND_DIR}`
    const suffixIndex = uri.lastIndexOf('/')
    const copyFilePath = `${dir}${uri.substring(suffixIndex)}`
    let file: fs.File | undefined
    try {
      const accessible = await fs.access(dir, fs.AccessModeType.EXIST)
      if (!accessible) {
        await fs.mkdir(dir)
      }
      file = await fs.open(uri, fs.OpenMode.READ_ONLY)
      await fs.copyFile(file.fd, `${dir}${uri.substring(suffixIndex)}`)
      // const files: string[] = await fs.listFile(dir)
      // console.log(`cached files: ${JSON.stringify(files)}`)
      return copyFilePath
    } catch (e) {
      const message = Errors.getErrorMessage(e)
      logger.error(TAG, `保存至临时目录失败: from: ${uri} to: ${copyFilePath} ` + message)
      throw Error(message)
    } finally {
      if (file) {
        fs.close(file)
      }
    }
  }

  static async clearMediaCache(context: Context): Promise<void> {
    const dir: string = `${context.cacheDir}/${FileProvider.PENDING_TO_SEND_DIR}`
    let file: fs.File | undefined
    try {
      const accessible = await fs.access(dir, fs.AccessModeType.EXIST)
      if (accessible) {
        await fs.rmdir(dir)
      }
    } catch (e) {
      const message = Errors.getErrorMessage(e)
      logger.error(TAG, `删除缓存目录失败 message: ${message} ` + message)
    } finally {
      if (file) {
        fs.close(file)
      }
    }
  }

  /**
   * 文本消息分割长度
   */
  static TEXT_MESSAGE_MAX_SIZE = 60 * 1024 //60kb

  /**
   * 创建文本消息
   * @param textMessage 文本内容
   * @returns
   */
  static createTextMessages(textMessage: string): Array<FileInfoModel> {
    const textArray = Strings.getSliceByBytes([], textMessage, FileProvider.TEXT_MESSAGE_MAX_SIZE)
    const files: FileInfoModel[] = []
    for (const text of textArray) {
      const size = buffer.byteLength(text, 'utf-8')
      files.push({
        id: util.generateRandomUUID(),
        fileName: `${util.generateRandomUUID()}.txt`,
        size: size,
        fileType: mime.getType('.txt') || "",
        preview: text
      })
    }
    return files
  }

  /**
   * 以只读模式打开指定路径的文件，使用后续手动关闭
   * @param filePath 文件路径 eg: file://docs/storage
   * @returns
   */
  static async getFile(filePath: string): Promise<fs.File> {
    return await new Promise<fs.File>((resolve, reject) => {
      fs.open(filePath, fs.OpenMode.READ_ONLY)
        .then((file: fs.File) => {
          resolve(file)
        })
        .catch((err: BusinessError) => {
          console.error("open file failed with error message: " + err.message + ", error code: " + err.code);
          reject(err)
        })
    })
  }

  /**
   * 根据文件大小返回分片大小
   * @param size
   * @returns
   */
  static getFilePortLength(size: number): number {
    if (size < 500 * FileProvider.ONE_MB) {
      return 1075 * FileProvider.ONE_KB
    } else if (size < FileProvider.ONE_GB) {
      return 825 * FileProvider.ONE_KB
    } else {
      return 1150 * FileProvider.ONE_KB
      // return 1075 * FileProvider.ONE_KB
    }
  }

  /**
   * 返回传输速度 单位：字节/s
   * @param size 传输大小byte
   * @param duration 传输时间ms
   * @returns
   */
  static getTransferSpeed(size: number, duration: number): number {
    return Number.parseFloat((size / (duration / 1000)).toFixed(2))
  }

  /**
   * 生成一个新的文件名，添加一个后缀（例如 "_1"）
   * @param filePath 文件路径
   * @returns
   */
  static async getUniqueFilepath(filePath: string): Promise<string> {
    let extension = '', fileName = filePath;
    const extIndex = filePath.lastIndexOf('.')
    if (extIndex > -1) {
      extension = filePath.substring(filePath.lastIndexOf('.'));
      fileName = filePath.substring(0, filePath.lastIndexOf('.'));
    }
    let counter = 1;
    let newFilePath = filePath;
    while (await fs.access(newFilePath, fs.AccessModeType.EXIST)) {
      newFilePath = `${fileName}_${counter}${extension}`;
      counter++;
    }
    return newFilePath
  }

  /**
   * 获取文件管理Download文件夹应用保存沙箱路径
   * @param context comm.Context
   * @returns
   */
  static async getDownloadSandboxDir(context: Context): Promise<string[]> {
    const options = new picker.DocumentSaveOptions();
    if (canIUse('SystemCapability.FileManagement.UserFileService')) {
      options.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
    }
    return new picker.DocumentViewPicker(context).save(options)
  }

  /**
   * 移动文件到Download/package文件夹
   * @param context
   * @param fileNames 移动的文件名
   * @returns
   */
  static async moveFilesToDownload(context: Context, fileNames: string[]): Promise<number> {
    let succeed: number = 0
    try {
      const documentSaveResult: string[] = await FileProvider.getDownloadSandboxDir(context)
      if (documentSaveResult && documentSaveResult.length > 0) {
        for (const fileName of fileNames) {
          const srcPath = `${FileProvider.getDefaultFileDir(context)}/${fileName}`;
          let destPath = `${new fileUri.FileUri(documentSaveResult[0]).path}/${fileName}`;
          console.info(`开始移动文件\nsrc: ${srcPath}\ndest: ${destPath}`)
          await fs.moveFile(srcPath, destPath)
          console.info(`文件移动完成 src: ${srcPath}\ntarget: ${destPath}`)
          succeed += 1
        }
      }
    } catch (e) {
      console.error(`文件移动失败: ${Errors.getErrorMessage(e)}`);
    }
    return succeed
  }

  /**
   * 删除文件
   * @param filePath 文件路径
   * @returns
   */
  static async deleteFile(filePath: string): Promise<void> {
    try {
      await fs.unlink(filePath)
    } catch (e) {
      console.error(`文件删除失败: ${Errors.getErrorMessage(e)}`);
    }
  }
}
