import { SizeConstant } from 'common';
import { Icon } from '.';
import { FileProvider } from '../utils';

@Component
export struct FileIcon {
  @Prop fileName: string = ''
  @Prop fileType: string = ''
  @Prop bgColor: ResourceColor = $r('app.color.card')

  build() {
    Stack() {
      Icon({
        src: FileProvider.getFileIconRes(this.fileName, this.fileType),
        iconColor: null
      })
    }
    .width(48)
    .height(48)
    .borderRadius(SizeConstant.RADIUS_L)
    .backgroundColor(this.bgColor)
  }
}