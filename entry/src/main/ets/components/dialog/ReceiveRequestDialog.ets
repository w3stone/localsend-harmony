import { Screens, SizeConstant, toast } from 'common'
import { DeviceIcon, IconButton } from '..'
import { PrepareUploadModel } from '../../model'
import { pasteboard } from '@kit.BasicServicesKit'
import { Routers } from '../../utils'

@CustomDialog
export struct ReceiveRequestDialog {
  @Consume('pages') page: NavPathStack;
  controller: CustomDialogController
  @Prop data: PrepareUploadModel | null = null
  onRejectClick?: (dialog: CustomDialogController) => void
  onAcceptClick?: (dialog: CustomDialogController) => void
  onCompleteClick?: (dialog: CustomDialogController) => void
  @State isStandaloneText: boolean = false

  build() {
    Column() {
      Blank().layoutWeight(1)
      DeviceIcon({ deviceType: this.data?.info?.deviceType, iconColor: $r('app.color.on_container') })
      Blank().height(SizeConstant.TEXT_XXL)
      Text(this.data?.info?.alias || "")
        .fontSize(36)
        .maxLines(1)
        .ellipsisMode(EllipsisMode.CENTER)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.on_container'))
        .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
      Blank().height(SizeConstant.TEXT_XXL)
      Row() {
        Text(this.data?.info == undefined ? "" : "#1")
          .fontSize(SizeConstant.TEXT_XL)
          .fontColor($r('app.color.on_container'))
          .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
          .backgroundColor($r('app.color.container'))
          .borderRadius(SizeConstant.RADIUS_M)
          .visibility(this.data?.info == undefined ? Visibility.None : Visibility.Visible)
        Blank().width(SizeConstant.TEXT_M)
        Text(this.data?.info?.deviceModel || "")
          .fontSize(SizeConstant.TEXT_XL)
          .fontColor($r('app.color.on_container'))
          .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
          .backgroundColor($r('app.color.container'))
          .borderRadius(SizeConstant.RADIUS_M)
      }

      Blank().height(SizeConstant.TEXT_XXL)

      //如果是单独的文本直接显示，不跳转到文件接收界面
      if (this.isStandaloneText) {
        Text($r('app.string.received_a_message'))
          .fontSize(SizeConstant.TEXT_XXL)
          .fontWeight(500)
          .fontColor($r('app.color.on_container'))
          .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
        Blank().height(SizeConstant.SPACE_L)

        Scroll() {
          Text(this.getTextIfIsStandaloneText())
            .fontSize(SizeConstant.TEXT_L)
            .fontColor($r('app.color.on_container'))
            .textSelectable(TextSelectableMode.SELECTABLE_FOCUSABLE)
        }
        .width('100%')
        .constraintSize({ maxHeight: 80 })
        .borderRadius(SizeConstant.RADIUS_M)
        .padding(SizeConstant.SPACE_M)
        .backgroundColor($r('app.color.container'))

        Blank().height(SizeConstant.SPACE_M)
        Button($r('app.string.copy'))
          .buttonStyle(ButtonStyleMode.NORMAL)
          .onClick(() => {
            this.copyTheMessage()
            if (this.onCompleteClick) {
              this.onCompleteClick(this.controller)
            }
          })
        Blank().height(34)
      } else {
        Text($r('app.string.send_file_request_text', this.getFilesCount()))
          .fontSize(SizeConstant.TEXT_XXL)
          .fontWeight(500)
          .fontColor($r('app.color.on_container'))
          .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
      }
      Blank().layoutWeight(1)
      //底部按钮
      if (this.isStandaloneText) {
        IconButton({
          text: $r('app.string.close'),
          icon: $r('app.media.ic_cancel_filled'),
          iconSize: SizeConstant.ICON_L,
          arrangement: FlexDirection.Row,
        }).onClick(() => {
          if (this.onCompleteClick) {
            this.onCompleteClick(this.controller)
          }
        })
      } else {
        IconButton({
          text: $r('app.string.setting'),
          icon: $r('app.media.ic_settings_filled'),
          iconSize: SizeConstant.ICON_L,
          arrangement: FlexDirection.Row,
        }).onClick(() => {
          toast.show('todo')
          // this.page.pushDestination({ name: Routers.RECEIVE_SETTING_PAGE, param: this.data })
        })
        Blank().height(34)
        Row() {
          IconButton({
            text: $r('app.string.reject'),
            icon: $r('app.media.ic_cancel_filled'),
            textColor: Color.White,
            iconColor: Color.White,
            arrangement: FlexDirection.Row,
            verticalPadding: SizeConstant.SPACE_EXTRA_S,
            horizontalPadding: SizeConstant.SPACE_M
          }).backgroundColor($r('app.color.error'))
            .borderRadius(SizeConstant.RADIUS_L)
            .onClick(() => {
              if (this.onRejectClick) {
                this.onRejectClick(this.controller)
              }
            })
          Blank().width(SizeConstant.SPACE_L)
          IconButton({
            text: $r('app.string.accept'),
            icon: $r('app.media.ic_ok_filled'),
            textColor: Color.White,
            iconColor: Color.White,
            arrangement: FlexDirection.Row,
            verticalPadding: SizeConstant.SPACE_EXTRA_S,
            horizontalPadding: SizeConstant.SPACE_M
          }).backgroundColor($r('app.color.primary'))
            .borderRadius(SizeConstant.RADIUS_L)
            .onClick(() => {
              if (this.onAcceptClick) {
                this.onAcceptClick(this.controller)
              }
            })
        }
      }
      Blank().height(SizeConstant.SPACE_XL)
    }
    .width('100%')
    .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L, bottom: Screens.getNavigationBarHeight() })
    // .backgroundColor($r('app.color.background'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
  }

  getFilesCount(): number {
    if (this.data?.files) {
      return Object.keys(this.data.files).length
    }
    return 1
  }

  aboutToAppear(): void {
    this.isStandaloneText = this._isStandaloneText()
  }

  _isStandaloneText(): boolean {
    if (this.data?.files) {
      const keys = Object.keys(this.data.files)
      if (keys.length === 1) {
        const file = this.data.files[keys[0]]
        return file.fileType?.toLowerCase() === 'text/plain'
      }
    }
    return false
  }

  getTextIfIsStandaloneText(): string | undefined {
    if (this.data?.files) {
      const keys = Object.keys(this.data.files)
      if (keys.length === 1) {
        const file = this.data.files[keys[0]]
        return file.preview
      }
    }
    return undefined
  }

  copyTheMessage() {
    const message = this.getTextIfIsStandaloneText()
    if (message) {
      const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, message);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      // 将数据放入剪切板
      systemPasteboard.setData(pasteboardData)
        .then(() => {
          toast.show($r('app.string.copy_succeed'));
        });
    }
  }
}