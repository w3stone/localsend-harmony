import { Screens, SizeConstant, toast } from 'common'
import { DeviceIcon, IconButton } from '..'
import { PrepareUploadModel } from '../../model'

@CustomDialog
export struct ReceiveRequestDialog {
  controller: CustomDialogController
  @Prop data?: PrepareUploadModel | null = null
  onRejectClick?: (dialog: CustomDialogController) => void
  onAcceptClick?: (dialog: CustomDialogController) => void

  build() {
    Column() {
      Blank().layoutWeight(1)
      DeviceIcon({ deviceType: this.data?.info?.deviceType, iconColor: $r('app.color.on_container') })
      Blank().height(SizeConstant.TEXT_L)
      Blank().height(SizeConstant.TEXT_XXL)
      Text(this.data?.info?.alias || "")
        .fontSize(36)
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
      Text($r('app.string.send_file_request_text', this.getFilesCount()))
        .fontSize(SizeConstant.TEXT_XXL)
        .fontWeight(500)
        .fontColor($r('app.color.on_container'))
        .padding({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
      Blank().layoutWeight(1)
      IconButton({
        text: $r('app.string.setting'),
        icon: $r('app.media.ic_settings_filled'),
        iconSize: SizeConstant.ICON_L,
        arrangement: FlexDirection.Row,
      }).onClick(() => {
        toast.show('设置')
      })

      Blank().height(SizeConstant.TEXT_XXL)
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

      Blank().height(SizeConstant.SPACE_XXL)
    }
    .width('100%')
    .padding({ bottom: Screens.getNavigationBarHeight() })
    .backgroundColor($r('app.color.background'))
  }

  getFilesCount(): number {
    if (this.data?.files) {
      return Object.keys(this.data.files).length
    }
    return 1
  }
}