import { DateUtil } from '@pura/harmony-utils'
import { SizeConstant } from 'common/src/main/ets/constant/SizeConstant'
import { FileIcon, Icon, SingleLineText } from '../../components'
import { Keys } from '../../constant'
import { ReceivedFileModel } from '../../model'
import { FileProvider } from '../../utils'
import { FileMenu } from './FileMenu'

@Component
export struct HistoryItem {
  @Prop data: ReceivedFileModel
  @Prop index: number
  @State isLongPress: boolean = false

  @Builder
  BindMenus() {
    FileMenu({ data: this.data })
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
    return `${DateUtil.getFormatDateStr(new Date())} - ${FileProvider.formatBytes(this.data.size)} - ${AppStorage.get(Keys.ALIAS)}`
  }
}