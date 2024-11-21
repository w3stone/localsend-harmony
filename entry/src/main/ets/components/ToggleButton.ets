export interface ToggleSwitchedEvent {
  isOn: boolean
  off: VoidCallback
}

@Component
export struct ToggleButton {
  private __isChangedByUser: boolean = false
  @Prop isOn: boolean
  onToggleSwitched?: (event: ToggleSwitchedEvent, isFromUser: boolean) => void

  build() {
    Toggle({ type: ToggleType.Switch, isOn: $$this.isOn })
      .onChange((isOn) => {
        if (this.onToggleSwitched) {
          this.onToggleSwitched({
            isOn: isOn, off: () => {
              this.isOn = false
            }
          } as ToggleSwitchedEvent, this.__isChangedByUser)
        }
        this.__isChangedByUser = false
      })
      .onClick(() => {
        this.__isChangedByUser = true
      })
  }
}