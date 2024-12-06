import { PrepareTransferModel, PrepareUploadModel, StringPair } from "../model";
import { SessionProvider } from "../utils";

export class FileReceptionService {
  /**
   * 返回允许接收的文件
   * @param upload
   * @returns
   */
  static getPrepareReceptionData(upload: PrepareUploadModel): PrepareTransferModel {
    const session = SessionProvider.generateSessionId()
    const ids = Object.keys(upload.files)
    const files: StringPair = {}
    for (const id of ids) {
      files[id] = SessionProvider.generateToken(session, id)
    }
    return new PrepareTransferModel(session, files)
  }
}