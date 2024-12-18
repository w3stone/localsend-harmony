import { SizeConstant } from 'common';
import { Icon } from '.';
import { FileProvider } from '../utils';
import { fileUri } from '@kit.CoreFileKit';

@Component
export struct FileIcon {
  @Prop fileName: string = ''
  @Prop fileType: string = ''
  @Prop bgColor: ResourceColor = $r('app.color.card')
  @Prop filePath: string|undefined

  build() {
    Stack() {
      if (this.filePath && FileProvider.isImage(this.fileType)) {
        Image(fileUri.getUriFromPath(this.filePath))
          .width(48)
          .height(48)
          .borderRadius(SizeConstant.RADIUS_L)
      }else {
        Icon({
          src: FileProvider.getFileIconRes(this.fileName, this.fileType),
          iconColor: null
        })
      }
    }
    .width(48)
    .height(48)
    .borderRadius(SizeConstant.RADIUS_L)
    .backgroundColor(this.bgColor)
  }
}