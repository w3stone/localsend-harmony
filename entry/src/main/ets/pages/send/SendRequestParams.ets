import { DeviceModel, FileInfoModel } from '../../model'
import { ListItemExtraInfo } from '../../transaction'

export class SendRequestParams extends ListItemExtraInfo {
  files: FileInfoModel[]
  target: DeviceModel

  constructor(files: FileInfoModel[], target: DeviceModel, id?: string, doDefaultTransition?: VoidCallback) {
    super(id, doDefaultTransition)
    this.files = files
    this.target = target
  }
}