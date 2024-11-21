import { SizeConstant } from 'common'
import { DeviceIcon } from '../../../../components'
import { Keys } from '../../../../constant'

@Extend(Column)
function itemStyles() {
  .alignItems(HorizontalAlign.Center)
  .width('100%')
  .padding({ top: SizeConstant.SPACE_S, bottom: SizeConstant.SPACE_S })
}

@Builder
export function DeviceTypeMenu() {
  Menu() {
    MenuItem() {
      Column() {
        DeviceIcon({ deviceType: 'mobile', iconColor: $r('app.color.on_container'), dimension: SizeConstant.ICON_XXL })
      }
      .itemStyles()
    }
    .onClick(() => AppStorage.set(Keys.DEVICE_TYPE, 'mobile'))

    MenuItem() {
      Column() {
        DeviceIcon({ deviceType: 'desktop', iconColor: $r('app.color.on_container'), dimension: SizeConstant.ICON_XXL })
      }
      .itemStyles()
    }
    .alignSelf(ItemAlign.Center)
    .onClick(() => AppStorage.set(Keys.DEVICE_TYPE, 'desktop'))

    MenuItem() {
      Column() {
        DeviceIcon({ deviceType: 'web', iconColor: $r('app.color.on_container'), dimension: SizeConstant.ICON_XXL })
      }
      .itemStyles()
    }
    .onClick(() => AppStorage.set(Keys.DEVICE_TYPE, 'web'))

    MenuItem() {
      Column() {
        DeviceIcon({ deviceType: 'headless', iconColor: $r('app.color.on_container'), dimension: SizeConstant.ICON_XXL })
      }
      .itemStyles()
    }
    .onClick(() => AppStorage.set(Keys.DEVICE_TYPE, 'headless'))

    MenuItem() {
      Column() {
        DeviceIcon({ deviceType: 'server', iconColor: $r('app.color.on_container'), dimension: SizeConstant.ICON_XXL })
      }
      .itemStyles()
    }
    .onClick(() => AppStorage.set(Keys.DEVICE_TYPE, 'server'))
  }
  .width(150)
}