export class EventType {
  static SCAN_DEVICE = 1
  /**
   * 收到其他设备发送文件请求 弹窗提示用户
   */
  static RECEIVE_SEND_REQUEST = 2 //接收到文件发送请求
  /**
   * 收到其他设备发送请求后，回复一个操作 拒绝or接受
   */
  static RECEIVE_SEND_REQUEST_ACTION = 3
  /**
   * 已同意其他设备发送文件，准备接收
   */
  static RECEIVING_FILE_ACTION = 4
  /**
   * 文件传输进度更新事件
   */
  static TRANSFER_PROGRESS_CHANGED_ACTION = 5
  /**
   * 文件服务 启动/关闭: ServiceAction
   */
  static SERVICE_ACTION = 6
  /**
   * 文件发送完成
   */
  static UPLOAD_FILE_COMPLETED = 7
  /**
   * 文件发送取消
   */
  static UPLOAD_FILE_CANCELED = 8
}