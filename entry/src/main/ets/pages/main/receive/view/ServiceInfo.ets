import { SizeConstant } from 'common'
import { Keys } from '../../../../constant'
import { DeviceProvider } from '../../../../utils'

@Component
export struct ServiceInfo {
  @State alias: string = AppStorage.get(Keys.ALIAS) || ''
  @State ip: string = DeviceProvider.getIpv4Address() || '--'
  @State port: number = AppStorage.get(Keys.PORT) || 53317

  build() {
    RelativeContainer() {
      Text($r('app.string.alias'))
        .fontSize(SizeConstant.TEXT_L)
        .fontColor($r('app.color.on_background'))
        .id('alias_text')
      Text(this.alias)
        .fontSize(SizeConstant.TEXT_L)
        .fontColor($r('app.color.on_background'))
        .margin({left: SizeConstant.SPACE_EXTRA_S})
        .alignRules({
          left: { anchor: "alias_text", align: HorizontalAlign.End },
        })
        .id('alias_value')
        .maxLines(1)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
        .constraintSize({maxWidth: '30%'})
        .ellipsisMode(EllipsisMode.CENTER)
        .wordBreak(WordBreak.BREAK_ALL)// 设置断行规则WordBreak.BREAK_ALL后实现字母为单位进行截断
        .textAlign(TextAlign.Start)
      Text('IP：')
        .fontSize(SizeConstant.TEXT_L)
        .fontColor($r('app.color.on_background'))
        .id('ip_text')
        .alignRules({
          left: { anchor: "alias_text", align: HorizontalAlign.Start },
          top: { anchor: "alias_text", align: VerticalAlign.Bottom }
        })
      Text(this.ip)
        .fontSize(SizeConstant.TEXT_L)
        .fontColor($r('app.color.on_background'))
        .margin({left: SizeConstant.SPACE_EXTRA_S})
        .alignRules({
          top: { anchor: "alias_value", align: VerticalAlign.Bottom },
          left: { anchor: "alias_value", align: HorizontalAlign.Start },
        })
        .id('ip_value')
      Text($r('app.string.port'))
        .fontSize(SizeConstant.TEXT_L)
        .fontColor($r('app.color.on_background'))
        .alignRules({
          left: { anchor: "ip_text", align: HorizontalAlign.Start },
          top: { anchor: "ip_text", align: VerticalAlign.Bottom }
        })
      Text(`${this.port}`)
        .fontSize(SizeConstant.TEXT_L)
        .fontColor($r('app.color.on_background'))
        .margin({left: SizeConstant.SPACE_EXTRA_S})
        .alignRules({
          top: { anchor: "ip_value", align: VerticalAlign.Bottom },
          left: { anchor: "alias_value", align: HorizontalAlign.Start },
        })
    }
    .padding(SizeConstant.RADIUS_L)
    .size({ width: 'auto', height: 'auto' })
    .backgroundColor($r('app.color.container'))
  }
}