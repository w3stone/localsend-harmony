import { DialogAction, DialogHelper } from '@pura/harmony-dialog'
import { Objects, SizeConstant } from 'common'
import { FileIcon, Icon, SingleLineText } from '../../components'
import { FileInfoModel } from '../../model'
import { FileProvider } from '../../utils'

@Component
export struct EditorItem {
  @Prop file: FileInfoModel
  @State isLongPress: boolean = false
  @State content: string = this.isTextPlain() ? this.file.preview || '' : this.file.fileName
  onChanged?: (newFile: FileInfoModel | null) => void

  build() {
    Row() {
      FileIcon({
        fileName: this.file.fileName,
        fileType: this.file.fileType,
        bgColor: $r('app.color.background')
      })

      Blank().width(SizeConstant.SPACE_M)
      Column() {
        SingleLineText({
          text: this.isTextPlain() ? this.file.preview || '' : this.file.fileName,
          overflow: this.isLongPress ? TextOverflow.MARQUEE : TextOverflow.Ellipsis
        })
          .width('100%')
        Blank().height(SizeConstant.SPACE_EXTRA_S)
        Text(FileProvider.formatBytes(this.file.size))
          .fontSize(SizeConstant.TEXT_L)
          .fontColor($r('app.color.on_container_secondary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Blank().width(SizeConstant.SPACE_S)
      if (this.isTextPlain()) {
        Icon({ src: $r('app.media.ic_edit') })
          .onClick(() => {
            this.onEditTextClick()
          })
        Blank().width(SizeConstant.SPACE_L)
      }
      Icon({ src: $r('app.media.ic_delete') })
        .onClick(() => {
          this.onDeleteClick()
        })
      Blank().width(SizeConstant.SPACE_M)
    }
    .padding(SizeConstant.SPACE_M)
    .borderRadius(SizeConstant.RADIUS_L)
    .backgroundColor($r('app.color.container'))
    .alignItems(VerticalAlign.Center)
    .gesture(LongPressGesture()
      .onAction(() => {
        this.isLongPress = true
      })
      .onActionEnd(() => {
        this.isLongPress = false
      })
    )
  }

  isTextPlain(): boolean {
    return this.file.fileType === 'text/plain'
  }

  onEditTextClick() {
    DialogHelper.showTextAreaDialog({
      title: $r('app.string.enter_message'),
      text: this.file.preview,
      inputBorder: {
        radius: SizeConstant.RADIUS_M
      },
      onAction: (action: DialogAction, _: string, content: string) => {
        if (action == DialogAction.TWO) {
          this.file = Objects.clone(this.file, FileProvider.createTextMessages(content)[0])
          if (this.onChanged) {
            this.onChanged(this.file)
          }
        }
      }
    })
  }

  onDeleteClick() {
    if (this.onChanged) {
      this.onChanged(null)
    }
  }
}