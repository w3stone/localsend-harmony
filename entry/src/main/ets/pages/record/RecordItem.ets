import { DateUtil } from '@pura/harmony-utils'
import { SizeConstant } from 'common/src/main/ets/constant/SizeConstant'
import { FileIcon, Icon, SingleLineText } from '../../components'
import { ReceiveRecordModel } from '../../model'
import { FileProvider } from '../../utils'
import { FileMenu } from './FileMenu'

@Component
export struct RecordItem {
  @Prop data: ReceiveRecordModel
  @Prop index: number
  @State isLongPress: boolean = false
  onRemoveRecordClick?: (id: number) => void

  @Builder
  BindMenus() {
    FileMenu({
      data: this.data, onRemoveRecordClick: this.onRemoveRecordClick
    })
  }

  build() {
    Row() {
      FileIcon({ fileType: this.data.fileType })
      Blank().width(SizeConstant.SPACE_M)
      Column() {
        SingleLineText({ text: this.data.fileName, overflow: this.isLongPress ? TextOverflow.MARQUEE : TextOverflow.Ellipsis })
          .width('100%')
        Blank().height(SizeConstant.SPACE_S)
        SingleLineText({
          text: this.getFileInfo(),
          textSize: SizeConstant.TEXT_L,
          overflow: this.isLongPress ? TextOverflow.MARQUEE : TextOverflow.Ellipsis
        }).width('100%')
      }
      .layoutWeight(1)

      Icon({ src: $r('app.media.ic_more') })
        .bindMenu(this.BindMenus)
    }
    .gesture(LongPressGesture()
      .onAction(() => {
        this.isLongPress = true
      })
      .onActionEnd(() => {
        this.isLongPress = false
      })
    )
  }

  getFileInfo(): string {
    return `${DateUtil.getFormatDateStr(this.data.sendAt)} - ${FileProvider.formatBytes(this.data.size)} - ${this.data.sender}`
  }
}