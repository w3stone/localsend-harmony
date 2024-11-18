//当收到文件发送请求时返回的结果类型
export enum ReceiveResultActionType {
  ACCEPT, //准备接收
  REJECT, //拒绝
  COMPLETE, //已接收，当发送的是单个文本时 直接接收
  ERROR //出错
}
