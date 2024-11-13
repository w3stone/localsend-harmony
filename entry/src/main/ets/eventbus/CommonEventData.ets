import { emitter } from '@kit.BasicServicesKit'
import { PrepareUploadModel, ReceiveResultAction } from '../model'

@Sendable
export class ValueEventData<T> {
  value: T

  constructor(value: T) {
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
export function ValueEvent<T>(value: T): emitter.EventData {
  return {
    data: new ValueEventData(value)
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