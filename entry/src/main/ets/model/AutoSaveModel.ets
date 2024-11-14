/**
 * 自动保存类型
 */
export enum AutoSaveModel {
  /**
   * 关闭自动保存
   */
  CLOSE,
  /**
   * 来自收藏夹类设备的发送请求自动保存
   */
  FAVORITES,
  /**
   * 来自网络内所有发送请求自动保存
   */
  ALL
}