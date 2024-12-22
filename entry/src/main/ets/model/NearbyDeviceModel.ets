import { DeviceModel } from '.';

@Sendable
export class NearbyDeviceModel extends DeviceModel {
  id: number = NaN
  key: string = ''
  isFavorited: number = 0

  static create(other: DeviceModel): NearbyDeviceModel {
    const device: NearbyDeviceModel = new NearbyDeviceModel()
    device.hostname = other.hostname
    device.alias = other.alias
    device.version = other.version // protocol version (major.minor)
    device.deviceModel = other.deviceModel // nullable
    device.deviceType = other.deviceType // nullable
    device.fingerprint = other.fingerprint
    device.port = other.port
    device.protocol = other.protocol // http | https
    device.download = other.download // if download API (section 5.2, 5.3) is active (optional, default: false)
    device.announce = other.announce

    device.key = `device_${other.hostname}`
    device.isFavorited = 0
    return device
  }
}