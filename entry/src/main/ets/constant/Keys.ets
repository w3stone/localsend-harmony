/**
 * AppStorage KEY
 */
export class Keys {
  private constructor() {
  }

  /**
   * 当前是否正处于文件传输状态
   * value = [boolean]
   */
  static CURRENTLY_TRANSFERRING_STATUS = 'CURRENTLY_TRANSFERRING_STATUS'
  /**
   * 当前设备别名
   * value = [string]
   */
  static ALIAS = 'alias'
  /**
   * 当前设备指纹
   * value = [string]
   */
  static FINGERPRINT = 'fingerprint'
  /**
   * 当前设置的自动保存类型
   * value = [AutoSaveModel]
   */
  static AUTO_SAVE_MODEL = 'AUTO_SAVE_MODEL'
  /**
   * 当前正在接收的请求sessionId
   * value = [string]
   */
  static CURRENTLY_RECEIVING_SESSION = 'CURRENTLY_RECEIVING_SESSION'
}