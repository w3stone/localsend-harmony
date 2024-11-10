import { BaseResponse } from "./BaseResponse";
import { util } from "@kit.ArkTS";

export class DeviceModel extends BaseResponse {
  key: string | undefined = undefined
  alias: string = ''
  version: string = "2.1" // protocol version (major.minor)
  deviceModel: string = "HarmonyOS" // nullable
  deviceType: string = "mobile" // mobile | desktop | web | headless | server, nullable
  fingerprint: string = ''
  port: number = 53317
  protocol: string = "http" // http | https
  download: boolean = false // if download API (section 5.2, 5.3) is active (optional, default: false)
  announce: boolean = false

  constructor() {
    super()
    this.fingerprint = util.generateRandomUUID()
  }
}