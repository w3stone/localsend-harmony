import { NavigationTitle } from '../../../../components'

@Component
export struct Setting {
  build() {
    NavigationTitle({ title: $r('app.string.select') }) {
      Column() {
        Button('接受文件弹窗')
          .onClick(() => {

          })
      }
      .width('100%')
      .height('100%')
    }
  }
}