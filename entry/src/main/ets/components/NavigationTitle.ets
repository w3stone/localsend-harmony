import { Screens, SizeConstant } from 'common'
import { LengthMetrics } from '@kit.ArkUI'

@Component
export struct NavigationTitle {
  @State title: ResourceStr = ''
  @State titleBackgroundColor: ResourceColor = $r('app.color.container')

  @Builder
  doNothingBuilder() {
  }

  @BuilderParam content: () => void = this.doNothingBuilder
  onBackClick?: () => void

  @Builder
  titleBar() {
    Row() {
      Text(this.title)
        .fontColor($r('app.color.on_background'))
        .fontSize(22)
        .fontWeight(600)
        .align(Alignment.Center)
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