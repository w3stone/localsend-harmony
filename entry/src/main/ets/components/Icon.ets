import { SizeConstant } from 'common'

@Component
export struct Icon {
  @Prop src: Resource
  @Prop spacing: Length = 0
  @Prop wh: Length = SizeConstant.ICON_XL
  click?: () => void

  build() {
    Image(this.src)
      .padding(this.spacing)
      .size({ width: this.wh, height: this.wh })
      .fillColor($r('app.color.icon'))
      .onClick(() => {
        if (this.click) {
          this.click()
        }
      })
  }
}