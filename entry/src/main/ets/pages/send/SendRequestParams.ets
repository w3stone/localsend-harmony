import { FileInfoModel, NearbyDeviceModel } from '../../model'
import { ListItemExtraInfo } from '../../transaction'

export class SendRequestParams extends ListItemExtraInfo {
  files: FileInfoModel[]
  target: NearbyDeviceModel

  constructor(files: FileInfoModel[], target: NearbyDeviceModel, id?: string, doDefaultTransition?: VoidCallback) {
    super(id, doDefaultTransition)
    this.files = files
    this.target = target
  }
}