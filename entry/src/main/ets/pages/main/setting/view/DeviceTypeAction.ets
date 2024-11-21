import { SizeConstant, Strings } from "common";
import { DeviceIcon, Icon } from "../../../../components";
import { Keys } from "../../../../constant";
import { DeviceTypeMenu } from "./DeviceTypeMenu";

@Component
export struct DeviceTypeAction {
  @StorageLink(Keys.DEVICE_TYPE) @Watch('onChanged') deviceType: string = ''
  @State type: string = this.deviceType
  onDeviceTypeChanged?: VoidCallback

  build() {
    RelativeContainer() {
      DeviceIcon({ deviceType: this.deviceType, dimension: SizeConstant.ICON_L, iconColor: $r('app.color.on_background') })
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          center: { anchor: '__container__', align: VerticalAlign.Center },
        })
      Icon({ src: $r('app.media.ic_spinner'), iconColor: $r('app.color.on_background') })
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End },
          center: { anchor: '__container__', align: VerticalAlign.Center },
        })
    }
    .borderRadius(SizeConstant.RADIUS_M)
    .backgroundColor($r('app.color.background'))
    .width(150)
    .height(48)
    .bindMenu(DeviceTypeMenu)
  }

  onChanged() {
    console.info(`deviceType: ${this.deviceType} isNotEmpty: ${Strings.isNotEmpty(this.deviceType)} type: ${this.type}`)
    if (this.onDeviceTypeChanged && Strings.isNotEmpty(this.deviceType) && this.type != this.deviceType) {
      this.onDeviceTypeChanged()
    }
  }
}