import resmgr from '@ohos.resourceManager';
import { formatString, getRandomNextNumber } from 'common';
import { DeviceModel } from '../model/DeviceModel';

export class LocalSend {
  static REGISTERED_DEVICE_LIST_KEY = "REGISTERED_DEVICE_LIST_KEY"

  static getRandomAlias(resource: resmgr.ResourceManager): string {
    let adjectives = resource.getStringArrayValueSync($r('app.strarray.alias_adjectives'))
    let fruits = resource.getStringArrayValueSync($r('app.strarray.alias_fruits'))

    let adjective = adjectives[getRandomNextNumber(0, adjectives.length)]
    let fruit = fruits[getRandomNextNumber(0, fruits.length)]

    let alias = resource.getStringSync($r('app.string.alias_combination'))
    return formatString(alias, adjective, fruit)
  }

  static addOrReplaceDevice(hostname: string, device: DeviceModel) {
    const allDevice: DeviceModel[] = AppStorage.get(LocalSend.REGISTERED_DEVICE_LIST_KEY) || []
    const key = `device_${hostname}`
    const findIndex = allDevice.findIndex((value: DeviceModel, index: number) => {
      value.key === key ? index : -1
    })
    if (findIndex > -1) {
      allDevice[findIndex] = device
    } else {
      let count = 0
      while (count < 40) {
        device.key = `${key}_${count}`
        allDevice.push(device)
        count += 1
      }
    }
    AppStorage.set(LocalSend.REGISTERED_DEVICE_LIST_KEY, allDevice)
  }

  static getDevice(hostname: string): DeviceModel | undefined {
    const key = `device_${hostname}`
    const allDevice: DeviceModel[] | undefined = AppStorage.get(LocalSend.REGISTERED_DEVICE_LIST_KEY)
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
}
