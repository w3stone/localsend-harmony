import { toast } from 'common'
import { ReceivedFileModel } from '../../model'
import { FileInfomation } from './FileInfomation'
import { DialogHelper } from '@pura/harmony-dialog'

@Component
export struct FileMenu {
  @Prop data: ReceivedFileModel

  @Builder
  FileInfomationContent() {
    FileInfomation({ data: this.data })
  }

  build() {
    Menu() {
      MenuItem({ content: $r('app.string.open_file') }).onClick(() => toast.show(`open_file: ${this.data.id}`))
      MenuItem({ content: $r('app.string.open_in_fm') }).onClick(() => toast.show(`open_in_fm: ${this.data.id}`))
      MenuItem({ content: $r('app.string.information') }).onClick(() => this.onInformationClick())
      MenuItem({ content: $r('app.string.delete_from_history') })
        .onClick(() => toast.show(`delete_from_history: ${this.data.id}`))
    }
    .fontColor($r('app.color.on_container'))
  }

  onInformationClick() {
    DialogHelper.showCustomContentDialog({
      title: $r('app.string.file_information'),
      buttons: [{ value: $r('app.string.close'), }],
      contentBuilder: () => {
        this.FileInfomationContent()
      }
    })
  }
}