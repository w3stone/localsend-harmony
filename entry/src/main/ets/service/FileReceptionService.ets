import { PrepareTransferModel, PrepareUploadModel, StringPair } from "../model";
import { SessionProvider } from "../utils";

export class FileReceptionService {

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