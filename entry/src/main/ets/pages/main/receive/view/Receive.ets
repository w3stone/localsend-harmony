import { util } from '@kit.ArkTS';
import { logger, SizeConstant, toast } from 'common';
import { WebService } from '../../../../service';
import { DeviceProvider } from '../../../../utils';
import { EventBus, EventType } from '../../../../eventbus';
import { Icon, IconMenu, NavigationTitle } from '../../../../components';
import { Keys } from '../../../../constant';
import { DialogAction, DialogHelper } from '@pura/harmony-dialog';
import { AutoSaveModel } from '../../../../model';

PersistentStorage.persistProp(Keys.ALIAS, DeviceProvider.getRandomAlias(getContext(this).resourceManager))
PersistentStorage.persistProp(Keys.FINGERPRINT, util.generateRandomUUID())
PersistentStorage.persistProp(Keys.AUTO_SAVE_MODEL, AutoSaveModel.CLOSE)
const service = new WebService(AppStorage.get<string>(Keys.ALIAS) || "Unknown Name")

@Component
export struct Receive {
  @StorageLink("DARK_MODE") isDark: boolean = false
  @StorageProp(Keys.ALIAS) alias: string = ""
  @StorageLink(Keys.AUTO_SAVE_MODEL) autoSaveModel: AutoSaveModel = AutoSaveModel.CLOSE

  build() {
    NavigationTitle({
      menus: [{
        icon: $r('app.media.ic_history'),
        index: 0
      }, {
        icon: $r('app.media.ic_detail'),
        index: 1
      }],
      onMenuClick: (menu: IconMenu) => {
        if (menu.index == 0) {
          toast.show('查看历史记录')
        } else if (menu.index == 1) {
          toast.show('查看Service')
        }
      }
    }) {
      Column() {
        Icon({ src: $r('app.media.logo'), dimension: 256 })
          .transition(TransitionEffect.rotate({ angle: '360deg' })
            .animation({
              duration: 15000,
              iterations: -1,
              curve: Curve.Linear
            }))
        Text(this.alias || "")
          .fontSize(36)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.on_container'))
          .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })

        Blank().layoutWeight(1)

        Text($r('app.string.auto_save'))
          .fontSize(SizeConstant.TEXT_L)
          .fontColor($r('app.color.on_container'))

        Blank().height(SizeConstant.SPACE_L)

        Row() {
          Text($r('app.string.closed'))
            .fontSize(SizeConstant.TEXT_L)
            .padding({
              left: SizeConstant.SPACE_XXL,
              top: SizeConstant.SPACE_M,
              right: SizeConstant.SPACE_L,
              bottom: SizeConstant.SPACE_M
            })
            .borderRadius({ topLeft: 50, bottomLeft: 50 })
            .borderWidth(px2vp(1))
            .fontColor(this.autoSaveModel == AutoSaveModel.CLOSE ? Color.White : $r('app.color.on_container'))
            .borderColor(this.autoSaveModel == AutoSaveModel.CLOSE ? $r('app.color.primary') : $r('app.color.on_container'))
            .backgroundColor(this.autoSaveModel == AutoSaveModel.CLOSE ? $r('app.color.primary') : Color.Transparent)
            .onClick(() => {
              this.autoSaveModel = AutoSaveModel.CLOSE
            })
          Text($r('app.string.favorites'))
            .fontSize(SizeConstant.TEXT_L)
            .padding({
              left: SizeConstant.SPACE_L,
              top: SizeConstant.SPACE_M,
              right: SizeConstant.SPACE_L,
              bottom: SizeConstant.SPACE_M
            })
            .borderWidth({
              left: 0,
              top: px2vp(1),
              right: 0,
              bottom: px2vp(1)
            })
            .fontColor(this.autoSaveModel == AutoSaveModel.FAVORITES ? Color.White : $r('app.color.on_container'))
            .borderColor(this.autoSaveModel == AutoSaveModel.FAVORITES ? $r('app.color.primary') : $r('app.color.on_container'))
            .backgroundColor(this.autoSaveModel == AutoSaveModel.FAVORITES ? $r('app.color.primary') : Color.Transparent)
            .onClick(() => {
              this.setAutoSaveTips(AutoSaveModel.FAVORITES)
            })
          Text($r('app.string.opened'))
            .fontSize(SizeConstant.TEXT_L)
            .padding({
              left: SizeConstant.SPACE_L,
              top: SizeConstant.SPACE_M,
              right: SizeConstant.SPACE_XXL,
              bottom: SizeConstant.SPACE_M
            })
            .borderRadius({ topRight: 50, bottomRight: 50 })
            .borderWidth(px2vp(1))
            .fontColor(this.autoSaveModel == AutoSaveModel.ALL ? Color.White : $r('app.color.on_container'))
            .borderColor(this.autoSaveModel == AutoSaveModel.ALL ? $r('app.color.primary') : $r('app.color.on_container'))
            .backgroundColor(this.autoSaveModel == AutoSaveModel.ALL ? $r('app.color.primary') : Color.Transparent)
            .onClick(() => {
              this.setAutoSaveTips(AutoSaveModel.ALL)
            })
        }

        Blank().height(SizeConstant.SPACE_XXL)
      }
      .size({ width: '100%', height: '100%' })
      .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
      .backgroundColor($r('app.color.container'))
    }
  }

  setAutoSaveTips(model: AutoSaveModel) {
    let title: ResourceStr
    let message: ResourceStr
    if (model == AutoSaveModel.FAVORITES) {
      title = $r('app.string.auto_save_favorites_title')
      message = $r('app.string.auto_save_favorites_tips')
    } else if (model == AutoSaveModel.ALL) {
      title = $r('app.string.auto_save')
      message = $r('app.string.auto_save_all_tips')
    } else {
      return
    }
    DialogHelper.showAlertDialog({
      title: title,
      content: message,
      primaryButton: {
        value: $r('app.string.cancel'),
        fontColor: $r('app.color.on_container_secondary'),
      },
      secondaryButton: $r('app.string.positive'),
      onAction: (action) => {
        if (action == DialogAction.TWO) {
          this.autoSaveModel = model
        }
      }
    })
  }

  aboutToAppear(): void {
    service.start()
    EventBus.getInstance().on(EventType.SCAN_DEVICE, () => {
      logger.info('ReceivePage', 'receive event: scanning device')
      service.scanOtherDevice()
    })
  }

  onBackPress(): boolean | void {
    logger.info('ReceivePage', 'onBackPress onBackPress')
  }

  aboutToDisappear(): void {
    service.stop()
    EventBus.getInstance().unregister(EventType.SCAN_DEVICE)
  }
}