import { IpAddress, logger, Screens, SizeConstant, toast } from 'common';
import { Icon, LoopImage } from '../../../../components';
import wifiManager from '@ohos.wifiManager';
import { JSON } from '@kit.ArkTS';
import { DeviceModel } from '../../../../model/DeviceModel';
import { LocalSend } from '../../../../utils/LocalSend';

@Component
export struct Send {
  @State ip: string = ''
  @StorageProp(LocalSend.REGISTERED_DEVICE_LIST_KEY) allDevice: DeviceModel[] = []

  build() {
    Column() {
      Text($r('app.string.select'))
        .fontSize(SizeConstant.TEXT_XXL)
        .fontColor($r('app.color.on_container'))
        .margin({ top: SizeConstant.SPACE_XL })
      Blank().height(SizeConstant.SPACE_M)
      Row() {
        IconButton({
          text: $r('app.string.file'), icon: $r('app.media.ic_file'), click: () => {
            toast.show("发送文件")
          }
        })
        Blank().width(SizeConstant.SPACE_M)
        IconButton({
          text: $r('app.string.folder'), icon: $r('app.media.ic_folder_filled'), click: () => {
            toast.show("发送文件")
          }
        })
        Blank().width(SizeConstant.SPACE_M)
        IconButton({
          text: $r('app.string.text'), icon: $r('app.media.ic_text_filled'), click: () => {
            toast.show("发送文件")
          }
        })
        Blank().width(SizeConstant.SPACE_M)
        IconButton({
          text: $r('app.string.clipboard'), icon: $r('app.media.ic_clipboard'), click: () => {
            toast.show("发送文件")
          }
        })
      }
      .width('100%')

      Row() {
        Text($r('app.string.nearby_devices'))
          .fontSize(SizeConstant.TEXT_XXL)
          .fontColor($r('app.color.on_container'))
        Blank().width(SizeConstant.SPACE_L)
        Icon({
          src: $r('app.media.ic_rotate'),
          spacing: SizeConstant.SPACE_EXTRA_S,
          click: () => {
            toast.show("查找设备")

          }
        })
        Blank().width(SizeConstant.SPACE_L)
        Icon({
          src: $r('app.media.ic_quickstart'),
          spacing: SizeConstant.SPACE_EXTRA_S,
          click: () => {
            toast.show("手动发送")
          }
        })
        Blank().width(SizeConstant.SPACE_L)
        Icon({
          src: $r('app.media.ic_favor'), spacing: SizeConstant.SPACE_EXTRA_S,
          click: () => {
            toast.show("收藏夹")
          }
        })
        Blank().width(SizeConstant.SPACE_L)
        Icon({
          src: $r('app.media.ic_settings'), spacing: SizeConstant.SPACE_EXTRA_S,
          click: () => {
            toast.show("发送模式")
          }
        })
      }
      .margin({ top: SizeConstant.SPACE_XL })

      Text(this.ip)
        .fontSize(SizeConstant.TEXT_XL)
        .fontColor($r('app.color.on_container'))

      Text(`设备数量: ${this.allDevice.length}`)
        .fontSize(SizeConstant.TEXT_XL)
        .fontColor($r('app.color.on_container'))

      //设备列表
      if (this.allDevice.length > 0) {
        List() {
          ForEach(
            this.allDevice,
            (item: DeviceModel) => {
              ListItem() {
                DeviceItem({ device: item })
              }
            },
            (item: DeviceModel, index: number) => `${item.key}_${index}`
          )
        }
        .listDirection(Axis.Vertical)
        .width('100%')
        .layoutWeight(1)
      } else {
        DeviceItem()
      }
    }
    .alignItems(HorizontalAlign.Start)
    .size({ width: '100%', height: '100%' })
    .padding({
      top: Screens.getStatusBarHeight(),
      right: SizeConstant.SPACE_L,
      left: SizeConstant.SPACE_L
    })
    .backgroundColor($r('app.color.container'))
  }

  aboutToAppear(): void {
    wifiManager.getLinkedInfo()
      .then((info) => {
        let checker: IpAddress = new IpAddress()
        this.ip = 'ssid: ' + info.ssid + ' ip: ' + checker.int2ip(info.ipAddress)
        logger.info("SendPage", `address = ${checker.int2ip(info.ipAddress)} LinkedInfo = ${JSON.stringify(info)}`)
      })
  }
}

@Component
struct IconButton {
  @Prop text: string | Resource
  @Prop icon: Resource
  click?: () => void

  build() {
    Column() {
      Icon({ src: this.icon })
      Blank().width(SizeConstant.SPACE_M)
      Text(this.text)
        .fontSize(SizeConstant.TEXT_M)
        .fontColor($r('app.color.on_container'))
    }
    .layoutWeight(1)
    .padding({ top: SizeConstant.SPACE_L, bottom: SizeConstant.SPACE_L })
    .backgroundColor($r('app.color.background'))
    .borderRadius(SizeConstant.RADIUS_L)
    .onClick(() => {
      if (this.click) {
        this.click()
      }
    })
  }
}

@Component
struct DeviceItem {
  @State device: DeviceModel | undefined = undefined

  build() {
    Row() {
      if (this.device) {
        Icon({ src: this.getIcon(this.device.deviceType), wh: 60 })
      } else {
        LoopImage({
          images: [
            $r('app.media.ic_mobile'), $r('app.media.ic_computer'),
            $r('app.media.ic_cli'), $r("app.media.ic_storage"), $r("app.media.ic_web")
          ]
        })
      }
      Blank().width(SizeConstant.TEXT_L)
      Column() {
        Text(this.device?.alias || "")
          .fontSize(SizeConstant.TEXT_XL)
          .fontColor($r('app.color.on_container'))
        Blank().height(SizeConstant.TEXT_M)
        Row() {
          Text(this.device == undefined ? "" : "#1")
            .fontSize(SizeConstant.TEXT_XL)
            .fontColor($r('app.color.on_container'))
            .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
            .backgroundColor($r('app.color.container'))
            .borderRadius(SizeConstant.RADIUS_M)
            .visibility(this.device == undefined ? Visibility.None : Visibility.Visible)
          Blank().width(SizeConstant.TEXT_M)
          Text(this.device?.deviceModel || "")
            .fontSize(SizeConstant.TEXT_XL)
            .fontColor($r('app.color.on_container'))
            .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
            .backgroundColor($r('app.color.container'))
            .borderRadius(SizeConstant.RADIUS_M)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Icon({ src: $r('app.media.ic_favor') }).align(Alignment.Center)
        .visibility(this.device == undefined ? Visibility.None : Visibility.Visible)
    }
    .width('100%')
    .margin({ top: SizeConstant.SPACE_L, bottom: SizeConstant.SPACE_L })
    .padding(SizeConstant.SPACE_L)
    .borderRadius(SizeConstant.RADIUS_L)
    .backgroundColor($r('app.color.background'))
  }

  //mobile | desktop | web | headless | server
  getIcon(deviceType: string): Resource {
    switch (deviceType) {
      case 'mobile':
        return $r('app.media.ic_mobile')
      case 'desktop':
        return $r('app.media.ic_computer')
      case 'server':
        return $r('app.media.ic_cli')
      case 'headless':
        return $r('app.media.ic_storage')
      case 'web':
        return $r('app.media.ic_web')
      default:
        return $r('app.media.ic_storage')
    }
  }
}