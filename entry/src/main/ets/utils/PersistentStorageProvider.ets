import { DeviceProvider } from '.';
import { Keys } from '../constant';
import { util } from '@kit.ArkTS';
import { AutoSaveModel, DeviceType } from '../model';
import { ConfigurationConstant } from '@kit.AbilityKit';

/**
 * 用于初始化所有需要持久化保存的数据
 */
export class PersistentStorageProvider {
  static init(context: Context) {
    //主题：默认跟随系统
    if (AppStorage.get(Keys.COLOR_MODE) == undefined) {
      PersistentStorage.persistProp(Keys.COLOR_MODE, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    }
    //PIN：默认不开启PIN
    if (AppStorage.get(Keys.USE_PIN_WHEN_RECEIVE) == undefined) {
      PersistentStorage.persistProp(Keys.USE_PIN_WHEN_RECEIVE, undefined)
    }
    //随机生成一个别名
    if (AppStorage.get(Keys.ALIAS) == undefined) {
      PersistentStorage.persistProp(Keys.ALIAS, DeviceProvider.getRandomAlias(context.resourceManager))
    }
    //设备类型
    if (AppStorage.get(Keys.DEVICE_TYPE) == undefined) {
      PersistentStorage.persistProp<DeviceType>(Keys.DEVICE_TYPE, 'web')
    }
    //设备型号
    if (AppStorage.get(Keys.DEVICE_MODE) == undefined) {
      PersistentStorage.persistProp(Keys.DEVICE_MODE, 'HarmonyOS')
    }
    //组播地址
    if (AppStorage.get(Keys.MULTICAST_ADDRESS) == undefined) {
      PersistentStorage.persistProp(Keys.MULTICAST_ADDRESS, '224.0.0.167')
    }
    //指纹
    if (AppStorage.get(Keys.FINGERPRINT) == undefined) {
      PersistentStorage.persistProp(Keys.FINGERPRINT, util.generateRandomUUID())
    }
    //自动保存模: 默认关闭
    if (AppStorage.get(Keys.AUTO_SAVE_MODEL) == undefined) {
      PersistentStorage.persistProp(Keys.AUTO_SAVE_MODEL, AutoSaveModel.CLOSE)
    }
    //Web服务监听端口
    if (AppStorage.get(Keys.PORT) == undefined) {
      PersistentStorage.persistProp(Keys.PORT, 53317)
    }
  }
}