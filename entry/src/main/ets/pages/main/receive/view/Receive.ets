import { Screens, SizeConstant } from 'common';
import { WebService, ResponseService } from '../../../../service';
import { LocalSend } from '../../../../utils';
import { util } from '@kit.ArkTS';
import { NetAddress } from '../../../../constant/LocalSend';

PersistentStorage.persistProp("alias", LocalSend.getRandomAlias(getContext(this).resourceManager))
PersistentStorage.persistProp("fingerprint", util.generateRandomUUID())
const service = new WebService(AppStorage.get<string>("alias") || "Unknown Name")

@Component
export struct Receive {
  @StorageLink("DARK_MODE") isDark: boolean = false
  @StorageLink("alias") alias: string = ""

  build() {
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
    }
    .size({ width: '100%', height: '100%' })
    .padding({ top: Screens.getStatusBarHeight(), left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
    .backgroundColor($r('app.color.container'))
  }

  aboutToAppear(): void {
    // this.startService()
    service.start()
  }

  aboutToDisappear(): void {
    // app.server?.stop()
    service.stop()
  }
}