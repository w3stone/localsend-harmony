import { FileInfoModel } from ".";

export interface ReceivedFileModel extends FileInfoModel {
  sender: string, //发送人
  sendAt: number, //发送时间
  filePath?: string | undefined
}