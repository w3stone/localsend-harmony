import { DeviceModel } from './DeviceModel'
import { DeviceProvider } from '../utils'
import { Keys } from '../constant'

@Sendable
export class MulticastModel extends DeviceModel {
  constructor(announce: boolean | undefined = undefined) {
    super()
    super.alias = AppStorage.get(Keys.ALIAS) || ''
    super.version = '2.1'
    super.port = AppStorage.get(Keys.PORT) || 53317
    super.announce = announce
    super.fingerprint = DeviceProvider.getDeviceFingerprint()
    super.deviceModel = AppStorage.get(Keys.DEVICE_MODE) || 'HarmonyOS'
    super.deviceType = AppStorage.get(Keys.DEVICE_TYPE) || 'mobile' // mobile | desktop | web | headless | server, nullable
    super.protocol = "http" // http | https
    super.download = false // if download API (section 5.2, 5.3) is active (optional, default: false)
    super.announce = announce
  }
}