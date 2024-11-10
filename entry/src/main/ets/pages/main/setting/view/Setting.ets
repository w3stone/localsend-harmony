
@Component
export struct Setting {
  build() {
    Column() {
      Text('ProfilePage')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}