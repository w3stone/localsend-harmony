import { Screens, SizeConstant } from 'common'
import { LengthMetrics } from '@kit.ArkUI'

@Component
export struct NavigationTitle {
  @State title: ResourceStr | undefined = undefined
  @State isHideBackButton: boolean = false
  @State titleBackgroundColor: ResourceColor = $r('app.color.background')

  @Builder
  doNothingBuilder() {
  }

  @BuilderParam content: VoidCallback = this.doNothingBuilder

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
    }
    .width('100%')
    .height('100%')
    .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
    .backgroundColor(this.titleBackgroundColor)
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
    .hideBackButton(this.isHideBackButton)
    .padding({ top: Screens.getStatusBarHeight() })
    .backgroundColor(this.titleBackgroundColor)
    .mode(NavigationMode.Stack)
  }
}

export interface IconMenu {
  icon: Resource
}