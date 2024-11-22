import { RandomUtil } from '@pura/harmony-utils'
import { SizeConstant } from 'common'
import { NavigationTitle } from '../../components'

@Component
export struct DeveloperTools {
  @State progress: number = 0
  @State total: number = 5665497088
  @State isCollapsed: boolean = false

  build() {
    NavDestination() {
      NavigationTitle({ title: '开发者工具' }) {
        Scroll() {
          Column() {
            Column() {
              Progress({ value: this.progress, total: this.total, type: ProgressType.Linear })
                .style({ strokeWidth: 10, enableSmoothEffect: true })
                .color($r('app.color.primary'))
              Text() {
                Span(`progress: ${this.progress}`)
                Span(` - total: ${this.total} - `)
                Span(`${((this.progress / this.total) * 100).toFixed(2)}%`)
              }

              Blank().height(SizeConstant.SPACE_M)
              Row() {
                Button('重置').onClick(() => {
                  this.progress = 0
                })
                Blank().width(SizeConstant.SPACE_M)
                Button('长按更新')
                  .onTouch(() => {
                    const next: number = RandomUtil.getRandomInt(10000, 500000)
                    if ((this.progress + next) > this.total) {
                      this.progress = this.total
                    } else {
                      this.progress += next
                    }
                  })
              }
            }
            .padding(SizeConstant.SPACE_M)
            .borderRadius(SizeConstant.RADIUS_M)
            .backgroundColor($r('app.color.container'))

            Blank().height(SizeConstant.SPACE_L)

            Column() {

            }
            .padding(SizeConstant.SPACE_M)
            .borderRadius(SizeConstant.RADIUS_M)
            .backgroundColor($r('app.color.container'))
          }
          .justifyContent(FlexAlign.End)
          .padding(SizeConstant.SPACE_L)
          .constraintSize({ minHeight: '100%', minWidth: '100%' })
        }
        .width('100%')
        .height('100%')
      }
    }
    .hideTitleBar(true)
  }
}