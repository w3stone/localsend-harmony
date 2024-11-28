import { SizeConstant } from 'common'
import { FileIcon, Icon, SingleLineText } from '../../components'
import { FileInfoModel } from '../../model'
import { FileProvider } from '../../utils'

@Component
export struct ReceiveItem {
  @Prop file: FileInfoModel
  @State isLongPress: boolean = false
  @State isModified: boolean = false

  build() {
    Row() {
      FileIcon({ fileType: this.file.fileType })
      Blank().width(SizeConstant.SPACE_M)
      Column() {
        SingleLineText({
          text: this.file.fileName,
          overflow: this.isLongPress ? TextOverflow.MARQUEE : TextOverflow.Ellipsis,
          textSize: SizeConstant.TEXT_XL
        }).width('100%')
        Text() {
          Span($r('app.string.unchanged'))
          Span(" - ")
          Span(FileProvider.formatBytes(this.file.size))
        }
        .fontColor($r('app.color.on_container_secondary'))
        .fontSize(SizeConstant.TEXT_L)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Blank().width(SizeConstant.SPACE_M)
      Icon({ src: $r('app.media.ic_edit') })
      Toggle({ type: ToggleType.Checkbox, isOn: true })
        .size({ width: 20, height: 20 })
        .selectedColor($r('app.color.primary'))
        .onChange((isOn: boolean) => {
          console.info('Component status:' + isOn)
        })
    }
    .width('100%')
  }
}