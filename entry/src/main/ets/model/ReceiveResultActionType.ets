//当收到文件发送请求时返回的结果类型
export enum ReceiveResultActionType {
  ACCEPT, //准备接收
  REJECT, //拒绝
  ERROR //出错
}
