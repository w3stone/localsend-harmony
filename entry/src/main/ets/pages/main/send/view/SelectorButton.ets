import { SizeConstant } from 'common'
import { IconButton } from '../../../../components'

@Component
export struct SelectorButton {
  @Prop text: string | Resource
  @Prop icon: Resource

  build() {
    Column() {
      IconButton({
        text: this.text,
        icon: this.icon,
        iconSize: SizeConstant.ICON_L,
        arrangement: FlexDirection.Column,
        space: SizeConstant.SPACE_M
      })
    }
    .width('100%')
    .padding({ top: SizeConstant.SPACE_L, bottom: SizeConstant.SPACE_L })
    .backgroundColor($r('app.color.background'))
    .borderRadius(SizeConstant.RADIUS_L)
  }
}