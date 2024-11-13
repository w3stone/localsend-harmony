import { DeviceModel } from './DeviceModel';
import { FileInfoKeyMap } from './Types';

export interface PrepareUploadModel {
  info: DeviceModel
  files: FileInfoKeyMap
}