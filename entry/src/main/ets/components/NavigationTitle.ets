import { Screens, SizeConstant } from 'common'
import { LengthMetrics } from '@kit.ArkUI'
import { Icon } from '.'

@Component
export struct NavigationTitle {
  @State title: ResourceStr | undefined = undefined
  @State titleBackgroundColor: ResourceColor = $r('app.color.container')
  @Prop menus: IconMenu[] = []
  onMenuClick?: (menu: IconMenu) => void

  @Builder
  doNothingBuilder() {
  }

  @BuilderParam content: VoidCallback = this.doNothingBuilder
  onBackClick?: VoidCallback

  @Builder
  titleBar() {
    Row() {
      if (this.title) {
        Text(this.title)
          .fontColor($r('app.color.on_background'))
          .fontSize(22)
          .fontWeight(600)
          .align(Alignment.Center)
      }
      Blank().layoutWeight(1)
      ForEach(this.menus, (item: IconMenu) => {
        Icon({
          src: item.icon,
          iconColor: $r('app.color.on_container'),
          spacing: 2,
        })
          .margin({ right: SizeConstant.SPACE_L })
          .onClick(() => {
            if (this.onMenuClick) {
              this.onMenuClick(item)
            }
          })
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
  }

  build() {
    Navigation() {
      this.content()
    }
    .title(this.titleBar, {
      paddingStart: LengthMetrics.vp(SizeConstant.SPACE_L),
      paddingEnd: LengthMetrics.vp(SizeConstant.SPACE_L),
    })
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton((this.onBackClick == undefined) ? true : false)
    .padding({ top: Screens.getStatusBarHeight() })
    .backgroundColor(this.titleBackgroundColor)
  }
}

export interface IconMenu {
  icon: Resource
  index: number
}