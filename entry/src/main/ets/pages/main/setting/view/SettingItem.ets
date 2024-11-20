import { SizeConstant } from 'common'

@Component
export struct SettingItem {
  @Prop text: ResourceStr = ''

  @Builder
  doNothingBuilder() {
  }

  @BuilderParam action: VoidCallback = this.doNothingBuilder

  build() {
    Row() {
      Text(this.text)
        .fontSize(SizeConstant.TEXT_XL)
        .fontColor($r('app.color.on_background'))
        .layoutWeight(1)
      this.action()
    }
    .padding(SizeConstant.SPACE_M)
  }
}