import { emitter } from '@kit.BasicServicesKit'
import { PrepareUploadModel, ReceiveResultAction, TransferProgressChangedAction } from '../model'

export class ValueEventData {
  value: object

  constructor(value: object) {
    this.value = value
  }
}

export class NumberEventData {
  value: number

  constructor(value: number) {
    this.value = value
  }
}

/**
 * send:
 * EventBus.getInstance().post(EventType.RECEIVE_SEND_REQUEST_ACTION, ValueEvent(data))
 *
 * receive:
 * EventBus.getInstance().once(EventType.RECEIVE_SEND_REQUEST_ACTION, (eventData: emitter.EventData) => {
 *    if (eventData.data?.data?.value === true) {}
 * }
 * @param value
 * @returns
 */
export function ValueEvent(value: object): emitter.EventData {
  return {
    data: new ValueEventData(value)
  }
}

export function NumberEvent(value: number): emitter.EventData {
  return {
    data: new NumberEventData(value)
  }
}

export function PrepareUploadEvent(value: PrepareUploadModel): emitter.EventData {
  return {
    data: value
  }
}

/**
 * 收到文件发送请求后通知WebService返回对方处理结果
 * @param value
 * @returns
 */
export function ReceiveResultActionEvent(value: ReceiveResultAction): emitter.EventData {
  return {
    data: value
  }
}

/**
 * 文件传输进度更新
 * @param value
 * @returns
 */
export function TransferFileProgressEvent(value: TransferProgressChangedAction): emitter.EventData {
  return {
    data: value
  }
}