import { AcceptReceiveModel } from ".";

export class FileReceiveQueueModel extends AcceptReceiveModel {
  constructor(receive: AcceptReceiveModel) {
    super(receive.sessionId, receive.files)
  }
}