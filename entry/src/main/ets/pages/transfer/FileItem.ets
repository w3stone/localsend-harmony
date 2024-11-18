import { SizeConstant } from 'common'
import { FileIcon, IconButton } from '../../components'
import { FileInfoModel, FileTransferInfo, FileTransferStatus } from '../../model'
import { FileProvider } from '../../utils'

@Component
export struct FileItem {
  @Prop file: FileInfoModel
  // @Prop status: FileTransferStatus = FileTransferStatus.QUEUE
  @Prop status: FileTransferInfo
  @State isLongPress: boolean = false

  build() {
    Row() {
      FileIcon({
        fileName: this.file.fileName,
        fileType: this.file.fileType,
        bgColor: $r('app.color.background')
      })

      Blank().width(SizeConstant.SPACE_M)
      Column() {
        Text(this.file.fileName)
          .fontSize(SizeConstant.TEXT_XL)
          .fontColor($r('app.color.on_container'))
          .maxLines(1)
          .width('100%')
          .textOverflow({
            overflow: this.isLongPress ? TextOverflow.MARQUEE : TextOverflow.Ellipsis
          })
          .ellipsisMode(EllipsisMode.CENTER)
          .wordBreak(WordBreak.BREAK_ALL)// 设置断行规则WordBreak.BREAK_ALL后实现字母为单位进行截断
          .textAlign(TextAlign.Start)
        Blank().height(SizeConstant.SPACE_EXTRA_S)
        if (this.status?.status === FileTransferStatus.TRANSFERRING) {
          Progress({
            value: this.status.progress || 0,
            total: this.file.size || 100,
            type: ProgressType.Linear
          }).style({ strokeWidth: 10, enableSmoothEffect: true })
            .color($r('app.color.primary'))
        } else if (this.status?.status === FileTransferStatus.ERROR) {
          IconButton({
            icon: $r('app.media.ic_detail'),
            iconColor: $r('app.color.warn'),
            text: $r('app.string.error'),
            textColor: $r('app.color.warn'),
            arrangement: FlexDirection.RowReverse
          })
        } else {
          Text(this.getStatusText())
            .fontSize(SizeConstant.TEXT_L)
            .fontColor($r('app.color.on_container_secondary'))
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Blank().width(SizeConstant.SPACE_S)
      Text(FileProvider.formatBytes(this.file.size))
        .fontSize(SizeConstant.TEXT_XL)
        .fontColor($r('app.color.on_container'))
    }
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

  getStatusText(): Resource {
    let text: Resource
    switch (this.status.status) {
      case FileTransferStatus.QUEUE:
        text = $r('app.string.queue')
        break;
      case FileTransferStatus.TRANSFERRING:
        text = $r('app.string.transferring')
        break;
      case FileTransferStatus.ERROR:
        text = $r('app.string.incorrect')
        break;
      case FileTransferStatus.SKIPPED:
        text = $r('app.string.skiped')
        break;
      case FileTransferStatus.COMPLETED:
        text = $r('app.string.completed')
        break;
      default:
        text = $r('app.string.cancel')
    }
    return text
  }
}