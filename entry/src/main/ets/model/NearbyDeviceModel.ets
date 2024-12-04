import { ObjectUtil } from "@pura/harmony-utils";
import { DeviceModel } from ".";

@Sendable
export class NearbyDeviceModel extends DeviceModel {
  id: number = NaN
  key: string = ''
  isFavorited: number = 0

  static create(other: DeviceModel): NearbyDeviceModel {
    const device: NearbyDeviceModel = new NearbyDeviceModel()
    ObjectUtil.assign(device, other)
    device.key = `device_${other.hostname}`
    device.isFavorited = 0
    return device
  }
}