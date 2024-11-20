import {
  BaseResponse,
  FileInfoKeyMap,
  FileInfoModel,
  FileTransferStatus,
  PrepareTransferModel,
  PrepareUploadModel,
  StringPair
} from '../model';
import { ContentType, HttpRequest, Terminator } from '../http';
import { DeviceProvider } from '../utils';
import { ApiConstant } from '../constant/ApiConstant';
import { logger, Objects } from 'common';
import { JSON } from '@kit.ArkTS';
import { DeviceModel } from '../model/DeviceModel';
import { UploaderServer } from './upload/UploadServer';
import { EventBus, EventType, TransferFileProgressEvent } from '../eventbus';
import { TransferException } from './upload/TransferException';

const TAG = 'WebClient'

export class WebClient {
  private static getCombinedURL(hostname: string, port: number, path: string) {
    return `http://${hostname}:${port}${path}`
  }

  /**
   * 像其他设备发送当前设备信息
   * @param alias
   * @param port
   */
  static register(target: DeviceModel) {
    if (!target.hostname) {
      logger.warn('WebClient', 'invalid hostname')
      return
    }
    const device: DeviceModel = DeviceProvider.getCurrentDevice()
    const url = WebClient.getCombinedURL(target.hostname, target.port, ApiConstant.REGISTER)
    const hostname = target.hostname
    HttpRequest.post(url, device)
      .then(resolve => {
        logger.info(TAG, '--->>> 当前设备信息已发送 response: ' + JSON.stringify(resolve))
        DeviceProvider.addOrReplaceDevice(hostname, resolve as DeviceModel)
      }, (reason: Error) => {
        logger.info(TAG, '--->>> 发送当前设备信息失败: ' + JSON.stringify(reason) + " url: " + url)
      })
  }

  static async prepareUpload(target: DeviceModel, files: Array<FileInfoModel>,
    callback: (term: Terminator) => void): Promise<PrepareTransferModel> {
    if (!target.hostname) {
      return Promise.reject('invalid hostname')
    }
    const filesMap: FileInfoKeyMap = {}
    for (const file of files) {
      filesMap[file.id] = Objects.clone({}, file)
      filesMap[file.id].filePath = undefined
      filesMap[file.id].metadata = undefined
    }
    const body: PrepareUploadModel = {
      info: DeviceProvider.getCurrentDevice(),
      files: filesMap
    }
    logger.info(TAG, `--->>> prepare-upload: ${JSON.stringify(body)}`)
    return await HttpRequest.post<PrepareTransferModel>(
      WebClient.getCombinedURL(target.hostname, target.port, ApiConstant.PREPARE_UPLOAD),
      body,
      ContentType.APPLICATION_JSON,
      callback
    )
  }

  static async cancel(target: DeviceModel, sessionId: string): Promise<void> {
    if (!target.hostname) {
      return Promise.reject()
    }
    const url = `${WebClient.getCombinedURL(target.hostname, target.port, ApiConstant.CANCEL)}?sessionId=${sessionId}`
    HttpRequest.post<BaseResponse>(url, null)
      .then()
      .catch((reason: object) => {
        logger.info(TAG, `cancel result error: ${JSON.stringify(reason)}`)
      })
  }

  static async upload(sessionId: string, target: DeviceModel, files: FileInfoModel[], fileTokens: StringPair,
    callback: (terminate: Terminator) => void): Promise<void> {
    if (!target.hostname) {
      throw new TransferException('invalid hostname')
    }
    const server = new UploaderServer(target.hostname, target.port)
    callback(server)
    try {
      for (const pending of files) {
        const url = `${ApiConstant.UPLOAD}?sessionId=${sessionId}&fileId=${pending.id}&token=${fileTokens[pending.id]}`
        await server.upload(url, pending, WebClient.onUploadProgressChanged)
      }
    } finally {
      server.disconnection()
    }
  }

  static async uploadFiles(context: Context, sessionId: string, target: DeviceModel, files: FileInfoModel[],
    fileTokens: StringPair, callback: (terminate: Terminator) => void): Promise<void> {
    if (!target.hostname) {
      throw new TransferException('invalid hostname')
    }
    const server = new UploaderServer(target.hostname, target.port)
    callback(server)
    try {
      for (const pending of files) {
        let url = `${ApiConstant.UPLOAD}?sessionId=${sessionId}&fileId=${pending.id}&token=${fileTokens[pending.id]}`
        url = WebClient.getCombinedURL(target.hostname, target.port, url)
        await server.createBackgroundTask(context, url, fileTokens[pending.id], pending.filePath!!)
      }
    } finally {
      server.disconnection()
    }
  }

  static onUploadProgressChanged(status: FileTransferStatus, progress: number, total: number, fileId: string, error?: object) {
    EventBus.getInstance().post(EventType.TRANSFER_PROGRESS_CHANGED_ACTION, TransferFileProgressEvent({
      status: status,
      progress: progress,
      total: total,
      fileId: fileId,
      error: error
    }))
  }
}