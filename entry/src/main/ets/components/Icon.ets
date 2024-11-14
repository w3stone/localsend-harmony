import { SizeConstant } from 'common'

@Component
export struct Icon {
  @Prop src: Resource
  @Prop iconColor?: ResourceColor | null = $r('app.color.icon')
  @Prop spacing: Length = 0
  @Prop dimension: Length = SizeConstant.ICON_XL
  click?: VoidCallback

  build() {
    if (this.iconColor) {
      Image(this.src)
        .padding(this.spacing)
        .size({ width: this.dimension, height: this.dimension })
        .fillColor(this.iconColor)
        .onClick(() => {
          if (this.click) {
            this.click()
          }
        })
    } else {
      Image(this.src)
        .padding(this.spacing)
        .size({ width: this.dimension, height: this.dimension })
        .onClick(() => {
          if (this.click) {
            this.click()
          }
        })
    }
  }
}