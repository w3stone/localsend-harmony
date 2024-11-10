import { Screens, SizeConstant } from 'common';

import { Receive } from '../receive';
import { Send } from '../send';
import { Setting } from '../setting';

@Component
export struct MainPage {
  @StorageLink("DARK_MODE") isDark: boolean = false
  @State currentTabIndex: number = 0
  private controller: TabsController = new TabsController()

  @Builder
  tabBar(text: Resource, icon: Resource, index: number) {
    Column() {
      Image(icon)
        .fillColor(this.currentTabIndex == index ? $r('app.color.primary') : $r('app.color.icon'))
        .size({ width: SizeConstant.ICON_L, height: SizeConstant.ICON_L })
      Blank().height(SizeConstant.SPACE_EXTRA_S)
      Text(text)
        .fontSize(SizeConstant.TEXT_M)
        .fontColor(this.currentTabIndex == index ? $r('app.color.primary') : $r('app.color.on_background'))
        .onClick(() => {
          this.currentTabIndex = index
          this.controller.changeIndex(index)
        })
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentTabIndex, controller: this.controller }) {
      TabContent() {
        Receive()
      }
      .tabBar(this.tabBar($r("app.string.receive"), $r('app.media.ic_wlan_filled'), 0))

      TabContent() {
        Send()
      }
      .tabBar(this.tabBar($r("app.string.send"), $r('app.media.ic_send_filled'), 1))

      TabContent() {
        Setting()
      }
      .tabBar(this.tabBar($r("app.string.setting"), $r('app.media.ic_settings_filled'), 2))
    }
    .scrollable(false)
    .animationMode(AnimationMode.NO_ANIMATION)
    .barMode(BarMode.Fixed)
    .barBackgroundColor($r('app.color.background'))
    .height('100%')
    .padding({ bottom: Screens.getNavigationBarHeight() })
    .onChange((index) => {
      this.currentTabIndex = index
    })
  }
}