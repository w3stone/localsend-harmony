import { SizeConstant } from 'common'

@Component
export struct IconButton {
  @Prop text: string | Resource = ""
  @Prop icon: PixelMap | ResourceStr | DrawableDescriptor

  build() {
    Column() {
      Image(this.icon)
        .size({ width: SizeConstant.ICON_XL, height: SizeConstant.ICON_XL })
        .fillColor($r('app.color.icon'))
      Blank().width(SizeConstant.SPACE_S)
      Text(this.text)
        .fontSize(SizeConstant.TEXT_M)
        .fontColor($r('app.color.on_container'))
    }
    .padding({
      left: SizeConstant.SPACE_L,
      right: SizeConstant.SPACE_L,
      top: SizeConstant.SPACE_L,
      bottom: SizeConstant.SPACE_L
    })
    .borderRadius(SizeConstant.RADIUS_L)
  }
}