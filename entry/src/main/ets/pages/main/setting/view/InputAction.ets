import { SizeConstant } from 'common'

@Component
export struct InputAction {
  @Link value: string
  @State _value: string = this.value
  @Prop inputType: InputType = InputType.Normal
  onChanged?: VoidCallback

  build() {
    TextInput({ text: $$this._value })
      .onChange(() => {
        if (this.value != this._value) {
          this.value = this._value
          if (this.onChanged) {
            this.onChanged()
          }
        }
      })
      .type(this.inputType)
      .fontSize(SizeConstant.TEXT_XL)
      .fontColor($r('app.color.on_background'))
      .maxLines(1)
      .maxLength(50)
      .width(150)
      .height(48)
      .textAlign(TextAlign.Center)
      .backgroundColor($r('app.color.background'))
      .borderRadius(SizeConstant.RADIUS_M)
  }
}