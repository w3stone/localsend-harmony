import { BaseDialogOptions, DialogAction } from '@pura/harmony-dialog'
import { SizeConstant, toast } from 'common'
import { Context } from '@kit.AbilityKit'

export interface MoveFileDialogOptions extends BaseDialogOptions {
  context: Context
  onMovementAuthorized: VoidCallback
}

@Builder
export function MoveFileDialogBuilder(options: MoveFileDialogOptions) {
  Column() {
    Blank().height(SizeConstant.SPACE_L)
    Text($r('app.string.file_transfer_complete'))
      .fontColor($r('app.color.on_container'))
      .fontSize(SizeConstant.TEXT_XXL)
      .fontWeight(500)
    Blank().height(SizeConstant.SPACE_L)
    Text($r('app.string.file_move_to_download_tips'))
      .fontColor($r('app.color.on_container'))
      .fontSize(SizeConstant.TEXT_L)
    Blank().height(SizeConstant.SPACE_L)
    SaveButton({
      icon: SaveIconStyle.FULL_FILLED,
      text: SaveDescription.SAVE_FILE,
      buttonType: ButtonType.Capsule
    }).onClick(async (_, result: SaveButtonOnClickResult) => {
      if (result == SaveButtonOnClickResult.SUCCESS) {
        options.onMovementAuthorized()
      } else {
        toast.show($r('app.string.file_move_to_download_error'))
      }
    })

    Blank().height(SizeConstant.SPACE_L)
    Button($r('app.string.cancel'), { buttonStyle: ButtonStyleMode.TEXTUAL })
      .width('100%')
      .fontColor($r('app.color.on_container_secondary'))
      .onClick(() => {
        if (options.onAction) {
          options.onAction(DialogAction.ONE, '', '')
        }
      })
  }
  .width(350)
  .padding(SizeConstant.SPACE_L)
  .backgroundColor($r('app.color.container'))
  .borderRadius(SizeConstant.RADIUS_L)
}