import { MulticastModel } from '../model';
import { HttpRequest } from '../http';
import { DeviceProvider } from '../utils';
import { ApiConstant } from '../constant/ApiConstant';
import { logger } from 'common';
import { JSON } from '@kit.ArkTS';
import { DeviceModel } from '../model/DeviceModel';
import { NetAddress } from '../constant/LocalSend';

const TAG = 'ResponseService'

export class ResponseService {
  /**
   * 像其他设备发送当前设备信息
   * @param alias
   * @param port
   */
  static register(hostname: string, alias: string, port: number) {
    const model: DeviceModel = new MulticastModel(alias, port, false)
    const url = ResponseService.getCombinedURL(hostname, ApiConstant.REGISTER)
    HttpRequest.post(url, model)
      .then(resolve => {
        logger.info(TAG, '--->>> 当前设备信息已发送 response: ' + JSON.stringify(resolve))
        DeviceProvider.addOrReplaceDevice(hostname, resolve as DeviceModel)
      }, (reason: Error) => {
        logger.info(TAG, '--->>> 发送当前设备信息失败: ' + JSON.stringify(reason) + " url: " + url)
      })
  }

  private static getCombinedURL(hostname: string, path: string) {
    return `http://${hostname}:${NetAddress.port}${path}`
  }
}