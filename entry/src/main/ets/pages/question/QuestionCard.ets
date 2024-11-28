import { SizeConstant } from "common"

@Component
export struct QuestionCard {
  @Prop title: ResourceStr
  @Prop text: ResourceStr

  build() {
    Column() {
      Text(this.title)
        .fontSize(SizeConstant.TEXT_XL)
        .fontColor($r('app.color.on_container'))
      Blank().height(SizeConstant.SPACE_L)
      Text(this.text)
        .fontSize(SizeConstant.TEXT_L)
        .fontColor($r('app.color.on_container'))
    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius(SizeConstant.RADIUS_L)
    .backgroundColor($r('app.color.container'))
    .padding(SizeConstant.SPACE_L)
  }
}