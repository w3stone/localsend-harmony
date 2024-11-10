import { DeviceModel } from './DeviceModel'

export class MulticastModel extends DeviceModel {
  constructor(alias: string, port: number, announce: boolean = true) {
    super()
    super.alias = alias
    super.port = port
    super.announce = announce
  }
}