import { Screens, SizeConstant } from 'common';
import { EventBus, EventType, ReceiveResultActionEvent } from '../../../eventbus';
import { PrepareUploadModel, ReceiveResultAction, ReceiveResultActionType, AutoSaveModel } from '../../../model';

import { Receive } from '../receive';
import { Send } from '../send';
import { Setting } from '../setting';
import { emitter } from '@kit.BasicServicesKit';
import { ReceiveRequestDialog } from '../../../components';
import { FileProvider, Routers } from '../../../utils';
import { Keys } from '../../../constant';

@Component
export struct MainPage {
  @StorageLink("DARK_MODE") isDark: boolean = false
  @StorageProp(Keys.AUTO_SAVE_MODEL) autoSaveModel: AutoSaveModel = AutoSaveModel.CLOSE
  @Consume('pages') pages: NavPathStack;
  @State currentTabIndex: number = 0
  private controller: TabsController = new TabsController()
  @State mSendFileRequestData: PrepareUploadModel | null = null
  mSendFileRequestDialog: CustomDialogController | null = new CustomDialogController({
    width: '100%',
    height: '60%',
    cornerRadius: {
      bottomLeft: 0,
      bottomRight: 0
    },
    offset: {
      dx: 0,
      //向下偏移显示在导航条下层
      dy: Screens.getNavigationBarHeight()
    },
    autoCancel: false,
    alignment: DialogAlignment.Bottom,
    openAnimation: {
      duration: 300,
      curve: Curve.Friction,
      playMode: PlayMode.Alternate,
    },
    closeAnimation: {
      duration: 300,
      curve: Curve.Friction,
      playMode: PlayMode.Alternate,
    },
    builder: ReceiveRequestDialog({
      data: this.mSendFileRequestData,
      onRejectClick: (dialog: CustomDialogController) => {
        EventBus.getInstance().post(
          EventType.RECEIVE_SEND_REQUEST_ACTION,
          ReceiveResultActionEvent({ action: ReceiveResultActionType.REJECT } as ReceiveResultAction)
        )
        dialog.close()
        this.mSendFileRequestData = null
      },
      onAcceptClick: (dialog: CustomDialogController) => {
        dialog.close()
        this.toReceivingPage()
      }
    }),
    onWillDismiss: () => {
      //阻止交互式关闭弹窗
    }
  })

  @Builder
  tabBar(text: Resource, icon: Resource, index: number) {
    Column() {
      Image(icon)
        .fillColor(this.currentTabIndex == index ? $r('app.color.primary') : $r('app.color.icon'))
        .size({ width: SizeConstant.ICON_L, height: SizeConstant.ICON_L })
      Blank().height(SizeConstant.SPACE_EXTRA_S)
      Text(text)
        .fontSize(SizeConstant.TEXT_M)
        .fontColor(this.currentTabIndex == index ? $r('app.color.primary') : $r('app.color.on_background'))
        .onClick(() => {
          this.currentTabIndex = index
          this.controller.changeIndex(index)
        })
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentTabIndex, controller: this.controller }) {
      TabContent() {
        Receive()
      }
      .tabBar(this.tabBar($r("app.string.receive"), $r('app.media.ic_wlan_filled'), 0))

      TabContent() {
        Send()
      }
      .tabBar(this.tabBar($r("app.string.send"), $r('app.media.ic_send_filled'), 1))

      TabContent() {
        Setting()
      }
      .tabBar(this.tabBar($r("app.string.setting"), $r('app.media.ic_settings_filled'), 2))
    }
    .scrollable(false)
    .animationMode(AnimationMode.NO_ANIMATION)
    .barMode(BarMode.Fixed)
    .barBackgroundColor($r('app.color.background'))
    .height('100%')
    .padding({ bottom: Screens.getNavigationBarHeight() })
    .onChange((index) => {
      this.currentTabIndex = index
    })
  }

  aboutToAppear(): void {
    //收到一个文件发送请求
    EventBus.getInstance().on(EventType.RECEIVE_SEND_REQUEST, (eventData: emitter.EventData) => {
      this.mSendFileRequestData = eventData.data as PrepareUploadModel
      if (this.mSendFileRequestData) {
        //设置正在处理文件发送请求，屏蔽掉其他文件发送请求
        FileProvider.setReceivingFiles(true)
        if (this.autoSaveModel == AutoSaveModel.FAVORITES) {
          //todo 检查发送请求的设备是否在收藏夹
          this.toReceivingPage()
        } else if (this.autoSaveModel == AutoSaveModel.ALL) {
          this.toReceivingPage()
        } else {
          if (this.mSendFileRequestData && this.mSendFileRequestDialog) {
            this.mSendFileRequestDialog.open()
            return
          }
        }
      }
      //回复处理错误
      EventBus.getInstance().post(
        EventType.RECEIVE_SEND_REQUEST_ACTION,
        ReceiveResultActionEvent({ action: ReceiveResultActionType.ERROR } as ReceiveResultAction)
      )
    })
  }

  aboutToDisappear(): void {
    this.mSendFileRequestData = null
    this.mSendFileRequestDialog = null
    EventBus.getInstance().unregister(EventType.RECEIVE_SEND_REQUEST)
  }

  toReceivingPage() {
    EventBus.getInstance().post(
      EventType.RECEIVE_SEND_REQUEST_ACTION,
      ReceiveResultActionEvent({ action: ReceiveResultActionType.ACCEPT } as ReceiveResultAction)
    )
    this.pages.pushPathByName(Routers.RECEIVING_PAGE, this.mSendFileRequestData?.files)
    this.mSendFileRequestData = null
  }
}