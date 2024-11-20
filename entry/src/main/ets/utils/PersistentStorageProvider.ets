import { DeviceProvider } from '.';
import { Keys } from '../constant';
import { ThemeModel } from '../theme/ThemeModel';
import { util } from '@kit.ArkTS';
import { AutoSaveModel } from '../model';

/**
 * 用于初始化所有需要持久化保存的数据
 */
export class PersistentStorageProvider {
  static init(context: Context) {
    //主题：默认跟随系统
    if (AppStorage.get(Keys.COLOR_MODE) == undefined) {
      PersistentStorage.persistProp(Keys.COLOR_MODE, ThemeModel.FLOW_SYSTEM)
    }
    //随机生成一个别名
    if (AppStorage.get(Keys.ALIAS) == undefined) {
      PersistentStorage.persistProp(Keys.ALIAS, DeviceProvider.getRandomAlias(context.resourceManager))
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
    if (AppStorage.get(Keys.AUTO_SAVE_MODEL) == undefined) {
      PersistentStorage.persistProp(Keys.AUTO_SAVE_MODEL, 53317)
    }
  }
}