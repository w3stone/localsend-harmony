import { SizeConstant } from "common"
import { Routers } from "../../../../utils"

@Component
export struct Footer {
  @Consume('pages') page: NavPathStack

  build() {
    Column() {
      Blank().height(SizeConstant.SPACE_L)
      Text($r('app.string.troubleshooting'))
        .fontSize(SizeConstant.TEXT_L)
        .fontColor($r('app.color.primary'))
        .onClick(() => {
          this.page.pushDestination({ name: Routers.QUESTION_PAGE })
        })
      Blank().height(SizeConstant.SPACE_XXL)
      Text($r("app.string.same_network_tips"))
        .fontSize(SizeConstant.TEXT_L)
        .fontColor($r('app.color.on_container_secondary'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}