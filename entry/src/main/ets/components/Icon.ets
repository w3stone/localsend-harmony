import { SizeConstant } from 'common'

@Component
export struct Icon {
  @Prop src: Resource
  @Prop iconColor?: ResourceColor | null = $r('app.color.icon')
  @Prop spacing: Length = 0
  @Prop dimension: Length = SizeConstant.ICON_XL

  build() {
    if (this.iconColor) {
      Image(this.src)
        .padding(this.spacing)
        .size({ width: this.dimension, height: this.dimension })
        .fillColor(this.iconColor)
    } else {
      Image(this.src)
        .padding(this.spacing)
        .size({ width: this.dimension, height: this.dimension })
    }
  }
}