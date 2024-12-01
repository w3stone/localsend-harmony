import { logger, Screens } from 'common';
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Configuration } from '@ohos.app.ability.Configuration';
import { DialogProvider } from '../utils/DialogProvider';
import { Keys } from '../constant';
import { PersistentStorageProvider } from '../utils';
import { ThemeProvider } from '../theme/ThemeProvider';
import { WindowUtils } from '../transaction/WindowUtils';

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam): void {

  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStorage.setOrCreate(Keys.WINDOW_STAGE, windowStage)

    WindowUtils.onWindowStageCreate(windowStage)

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        return
      }
      PersistentStorageProvider.init(this.context)

      //系统是否是深色模式
      let mode = this.context.config.colorMode
      ThemeProvider.setSystemColorModeUpdate(mode)
      DialogProvider.init(this.context)
      logger.error("EntryAbility", "init")

      let win: window.Window = windowStage.getMainWindowSync() // 获取应用主窗口
      win.setWindowLayoutFullScreen(true)
      AppStorage.setOrCreate('MainWindow', win)
      Screens.init(win)
    })
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    let newColorMode = newConfig.colorMode;
    let currentColorMode = AppStorage.get<ConfigurationConstant.ColorMode>(Keys.SYSTEM_COLOR_MODE);
    if (newColorMode == currentColorMode) {
      return
    }
    ThemeProvider.setSystemColorModeUpdate(newColorMode)
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }

  onDestroy(): void {

  }
}
