import { DeviceModel } from './DeviceModel'
import { DeviceProvider } from '../utils'

@Sendable
export class MulticastModel extends DeviceModel {
  constructor(alias: string, port: number, announce: boolean | undefined = undefined) {
    super()
    super.alias = alias
    super.version = '2.1'
    super.port = port
    super.announce = announce
    super.fingerprint = DeviceProvider.getDeviceFingerprint()
    super.deviceModel = 'HarmonyOS'
    super.deviceType = 'mobile' // mobile | desktop | web | headless | server, nullable
    super.protocol = "http" // http | https
    super.download = false // if download API (section 5.2, 5.3) is active (optional, default: false)
    super.announce = announce
  }
}