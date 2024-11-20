import resmgr from '@ohos.resourceManager';
import { getRandomNextNumber, Objects, Strings } from 'common';
import { DeviceModel } from '../model/DeviceModel';
import { util } from '@kit.ArkTS';
import { Keys } from '../constant';
import { MulticastModel } from '../model';
import wifiManager from '@ohos.wifiManager';

export class DeviceProvider {
  static REGISTERED_DEVICE_LIST_KEY = "REGISTERED_DEVICE_LIST_KEY"

  static getDeviceFingerprint(): string {
    return AppStorage.get(Keys.FINGERPRINT) || util.generateRandomUUID()
  }

  static getRandomAlias(resource: resmgr.ResourceManager): string {
    let adjectives = resource.getStringArrayValueSync($r('app.strarray.alias_adjectives'))
    let fruits = resource.getStringArrayValueSync($r('app.strarray.alias_fruits'))

    let adjective = adjectives[getRandomNextNumber(0, adjectives.length)]
    let fruit = fruits[getRandomNextNumber(0, fruits.length)]

    let alias = resource.getStringSync($r('app.string.alias_combination'))
    return Strings.formatString(alias, adjective, fruit)
  }

  static addOrReplaceDevice(hostname: string, device: DeviceModel) {
    const allDevice: DeviceModel[] = AppStorage.get(DeviceProvider.REGISTERED_DEVICE_LIST_KEY) || []
    const key = `device_${hostname}`
    let findIndex = -1
    findIndex = allDevice.findIndex((item: DeviceModel) => item.key === key)
    device.key = key
    device.hostname = hostname
    if (findIndex > -1) {
      allDevice[findIndex] = Objects.clone(allDevice[findIndex], device)
    } else {
      allDevice.push(device)
    }
    AppStorage.setOrCreate(DeviceProvider.REGISTERED_DEVICE_LIST_KEY, allDevice)
  }

  static getDevice(hostname: string): DeviceModel | undefined {
    const key = `device_${hostname}`
    const allDevice: DeviceModel[] | undefined = AppStorage.get(DeviceProvider.REGISTERED_DEVICE_LIST_KEY)
    if (allDevice) {
      const findIndex = allDevice.findIndex((value: DeviceModel) => value.key === key)
      if (findIndex > -1) {
        return allDevice[findIndex]
      }
    }
    return undefined
  }

  static getAllDevice(): Array<DeviceModel> {
    return AppStorage.get(DeviceProvider.REGISTERED_DEVICE_LIST_KEY) || []
  }

  static getCurrentDevice(): DeviceModel {
    return new MulticastModel()
  }

  static getIpv4Address(): string {
    const ipNumber = wifiManager.getIpInfo().ipAddress
    if (ipNumber <= 0) {
      return ""
    }
    const ip3 = (ipNumber << 0) >>> 24;
    const ip2 = (ipNumber << 8) >>> 24;
    const ip1 = (ipNumber << 16) >>> 24;
    const ip0 = (ipNumber << 24) >>> 24
    return ip3 + "." + ip2 + "." + ip1 + "." + ip0
  }
}
