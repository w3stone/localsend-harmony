import { logger, Screens } from 'common';
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Configuration } from '@ohos.app.ability.Configuration';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    window.getLastWindow(this.context, async (_, win) => {
      //系统是否是深色模式
      let mode = this.context.config.colorMode
      AppStorage.setOrCreate("SYSTEM_COLOR_MODE", mode)
      let isDark: boolean = (mode == ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
      AppStorage.setOrCreate("DARK_MODE", isDark)
      //
      // win.setWindowLayoutFullScreen(true)
      // let area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      // logger.error("EntryAbility", "getWindowAvoidArea")
      // AppStorage.setOrCreate("STATUS_BAR_HEIGHT", area.topRect.height)
      // logger.error("EntryAbility", "setOrCreate")
      // ScreenUtils.init(area)
      logger.error("EntryAbility", "init")
    })
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStorage.setOrCreate("windowStage", windowStage)
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        return
      }
      let win: window.Window = windowStage.getMainWindowSync() // 获取应用主窗口
      win.setWindowLayoutFullScreen(true)
      AppStorage.setOrCreate('MainWindow', win)
      Screens.init(win)
    })
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    let newColorMode = newConfig.colorMode;
    let currentColorMode = AppStorage.get<ConfigurationConstant.ColorMode>('SYSTEM_COLOR_MODE');
    if (newColorMode == currentColorMode) {
      return
    }
    AppStorage.setOrCreate("SYSTEM_COLOR_MODE", newColorMode)
    // 更新缓存中的颜色模式
    let isDark: boolean = (newColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
    AppStorage.setOrCreate("DARK_MODE", isDark)
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
