import { BaseResponse } from "./BaseResponse";

@Sendable
export class DeviceModel extends BaseResponse {
  hostname: string = ''
  alias: string = ''
  version: string = "" // protocol version (major.minor)
  deviceModel: string = "" // nullable
  deviceType: string = "" // mobile | desktop | web | headless | server, nullable
  fingerprint: string = ''
  port: number = 53317
  protocol: string = "http" // http | https
  download?: boolean // if download API (section 5.2, 5.3) is active (optional, default: false)
  announce?: boolean
}