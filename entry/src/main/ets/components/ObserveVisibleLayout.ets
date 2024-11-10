/**
 * 用来监听组件当前在界面上是否可见
 */
@Component
export struct ObserveVisibleLayout {
  @Builder
  doNothingBuilder() {
  }

  @BuilderParam content: () => void = this.doNothingBuilder
  onVisibleChanged?: (isVisible: boolean) => void

  build() {
    Stack() {
      this.content()
    }
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (isVisible && currentRatio >= 1.0) {
        if (this.onVisibleChanged) {
          this.onVisibleChanged(true)
        }
      }
      if (!isVisible && currentRatio <= 0.0) {
        if (this.onVisibleChanged) {
          this.onVisibleChanged(false)
        }
      }
    })
  }
}