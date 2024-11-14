import resmgr from '@ohos.resourceManager';
import { formatString, getRandomNextNumber } from 'common';
import { DeviceModel } from '../model/DeviceModel';
import { util } from '@kit.ArkTS';
import { Keys } from '../constant';

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
    return formatString(alias, adjective, fruit)
  }

  static addOrReplaceDevice(hostname: string, device: DeviceModel) {
    const allDevice: DeviceModel[] = AppStorage.get(DeviceProvider.REGISTERED_DEVICE_LIST_KEY) || []
    const key = `device_${hostname}`
    let findIndex = -1
    for (let i = 0; i < allDevice.length; i++) {
      if (allDevice[i]!!.key == key) {
        findIndex = i
        break
      }
    }
    device.key = key
    if (findIndex > -1) {
      allDevice[findIndex] = device
    } else {
      allDevice.push(device)
    }
    AppStorage.setOrCreate(DeviceProvider.REGISTERED_DEVICE_LIST_KEY, allDevice)
  }

  static getDevice(hostname: string): DeviceModel | undefined {
    const key = `device_${hostname}`
    const allDevice: DeviceModel[] | undefined = AppStorage.get(DeviceProvider.REGISTERED_DEVICE_LIST_KEY)
    if (allDevice) {
      const findIndex = allDevice.findIndex((value: DeviceModel, index: number) => {
        value.key === key ? index : -1
      })
      if (findIndex > -1) {
        return allDevice[findIndex]
      }
    }
    return undefined
  }

  static getAllDevice(): Array<DeviceModel> {
    return AppStorage.get(DeviceProvider.REGISTERED_DEVICE_LIST_KEY) || []
  }
}
