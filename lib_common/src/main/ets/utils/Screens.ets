import window from '@ohos.window'
import { logger } from '.'
import { display } from '@kit.ArkUI'

export class Screens {
  static statusBarHeight: number
  static navigationBarHeight: number

  static init(win: window.Window) {
    Screens.statusBarHeight = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)
    Screens.navigationBarHeight = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height)
    logger.debug("Screens", `init: statusBarHeight=${Screens.statusBarHeight} navigationBarHeight=${Screens.navigationBarHeight}`)
  }

  static getStatusBarHeight(): number {
    return Screens.statusBarHeight
  }

  static getNavigationBarHeight(): number {
    return Screens.navigationBarHeight
  }

  static getScreenHeight(): number {
    return display.getDefaultDisplaySync().height
  }

  static getScreenWidth(): number {
    return display.getDefaultDisplaySync().width
  }
}