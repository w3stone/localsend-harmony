import { SizeConstant } from 'common';
import { IconButton } from '.';

@Component
export struct SpinnerButton {
  @Prop text: ResourceStr

  build() {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      IconButton({ text: this.text, icon: $r('app.media.ic_spinner'), arrangement: FlexDirection.RowReverse })
    }
    .borderRadius(SizeConstant.RADIUS_M)
    .backgroundColor($r('app.color.background'))
    .padding({
      left: SizeConstant.SPACE_XL,
      top: SizeConstant.SPACE_S,
      right: SizeConstant.SPACE_L,
      bottom: SizeConstant.SPACE_S
    })
  }
}