import { AnimatorOptions, AnimatorResult } from '@kit.ArkUI';
import { ObserveVisibleLayout } from './ObserveVisibleLayout';

@Component
export struct LoopImage {
  @Prop images: Array<Resource>
  @State wh: Length = 64
  @State alpha: number = 0
  @State current: number = 0 //当前Images下标
  animator: AnimatorResult | null = null
  timer: number | undefined

  build() {
    if (this.images && this.images.length > 0) {
      ObserveVisibleLayout({
        onVisibleChanged: (isVisible: boolean) => {
          if (isVisible) {
            this.startAnim()
          } else {
            this.stopAnim()
          }
        }
      }) {
        Image(this.images[this.current])
          .size({ width: this.wh, height: this.wh })
          .fillColor($r('app.color.icon'))
          .opacity(this.alpha)
      }
    }
  }

  aboutToDisappear(): void {
    this.stopAnim(true)
  }

  private startAnim() {
    let context: UIContext = this.getUIContext()
    if (context) {
      if (!this.animator) {
         let options:AnimatorOptions = {
          duration: 1000,
          easing: "smooth",
          delay: 0,
          fill: "none",
          direction: "normal",
          iterations: 1,
          begin: this.alpha,
          end: 1
        }
        this.animator = context.createAnimator(options)
        this.animator.onFrame = (progress: number) => {
          if (progress != 0) {
            this.alpha = progress
          }
        }
        this.animator.onFinish = () => {
          this.timer = setTimeout(() => {
            this.alpha = 0
            this.setNextImage()
            this.animator?.play()
          }, 3000)
        }
      }
      this.animator.play()
    }
  }

  private stopAnim(isDisappear: boolean = false) {

    if (this.animator) {
      if (isDisappear) {
        this.animator.cancel()
        this.animator = null
        this.alpha = 0
      } else {
        this.animator.pause()
      }
    }
    if (this.timer != undefined) {
      clearTimeout(this.timer)
    }
  }

  private setNextImage() {
    if (this.current < this.images.length - 1) {
      this.current += 1
    } else {
      this.current = 0
    }
  }
}