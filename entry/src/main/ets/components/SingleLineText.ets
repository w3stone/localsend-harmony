import { SizeConstant } from "common"
import { TextModifier } from "@kit.ArkUI"

@Component
export struct SingleLineText {
  @Prop text: ResourceStr = ''
  @Prop textSize: Length = SizeConstant.TEXT_XL
  @Prop textColor: ResourceColor = $r('app.color.on_container')
  @Prop overflow: TextOverflow = TextOverflow.Ellipsis
  @Prop textLineHeight: number | string | Resource
  @Prop modifier: TextModifier

  build() {
    Text(this.text)
      .fontSize(this.textSize)
      .fontColor(this.textColor)
      .maxLines(1)
      .textOverflow({
        overflow: this.overflow
      })
      .attributeModifier(this.modifier)
      .ellipsisMode(EllipsisMode.CENTER)
      .wordBreak(WordBreak.BREAK_ALL)// 设置断行规则WordBreak.BREAK_ALL后实现字母为单位进行截断
      .textAlign(TextAlign.Start)
  }
}