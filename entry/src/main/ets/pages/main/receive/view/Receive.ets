import { util } from '@kit.ArkTS';
import { logger, Screens, SizeConstant } from 'common';
import { ResponseService, WebService } from '../../../../service';
import { DeviceProvider, Routers, } from '../../../../utils';
import { NetAddress } from '../../../../constant/LocalSend';
import { EventBus, EventType } from '../../../../eventbus';
import { NavigationTitle } from '../../../../components';

PersistentStorage.persistProp("alias", DeviceProvider.getRandomAlias(getContext(this).resourceManager))
PersistentStorage.persistProp("fingerprint", util.generateRandomUUID())
const service = new WebService(AppStorage.get<string>("alias") || "Unknown Name")

@Component
export struct Receive {
  @StorageLink("DARK_MODE") isDark: boolean = false
  @StorageLink("alias") alias: string = ""
  @Consume('pages') pages: NavPathStack;

  build() {
    NavigationTitle({ title: $r('app.string.receive') }) {
      Column() {
        Text(`SYSTEM_COLOR_MODE: ${AppStorage.get("SYSTEM_COLOR_MODE")}`)
        Text(`DARK_MODE: ${AppStorage.get("DARK_MODE")}`)
        Blank().height(10)
        Button("启动WebSever")
          .onClick(() => {
            service.start()
          })
        Blank().height(10)
        Button("停止WebSever")
          .onClick(() => {
            service.stop()
          })
        Button("Register")
          .onClick(() => {
            ResponseService.register("192.168.2.26", this.alias, NetAddress.port!!)
          })
        Button("跳转到接收文件界面")
          .onClick(() => {
            this.pages.pushPath({ name: Routers.RECEIVING_PAGE })
          })
      }
      .size({ width: '100%', height: '100%' })
      .padding({ top: Screens.getStatusBarHeight(), left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
      .backgroundColor($r('app.color.container'))
    }
  }

  aboutToAppear(): void {
    service.start()
    EventBus.getInstance().on(EventType.SCAN_DEVICE, () => {
      logger.info('ReceivePage', 'receive event: scanning device')
      service.scanOtherDevice()
    })
  }

  aboutToDisappear(): void {
    service.stop()
    EventBus.getInstance().unregister(EventType.SCAN_DEVICE)
  }
}