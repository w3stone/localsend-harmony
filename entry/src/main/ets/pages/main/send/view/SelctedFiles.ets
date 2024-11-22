import { logger, SizeConstant } from 'common';
import { FileIcon, Icon, IconButton } from '../../../../components';
import { FileInfoModel } from '../../../../model';
import { FileProvider, ObservedArray, Routers } from '../../../../utils';
import { picker } from '@kit.CoreFileKit';

@Component
export struct SelectedFiles {
  @Consume('pages') pages: NavPathStack
  @Link files: ObservedArray<FileInfoModel>
  onAppendClick?: () => void = undefined

  build() {
    Column() {
      Row() {
        Column() {
          Text($r('app.string.number_of_files', this.files?.length || 0))
            .fontSize(SizeConstant.TEXT_XL)
            .fontColor($r('app.color.on_background'))
          Text($r('app.string.size_text', this.getTotalSize()))
            .fontSize(SizeConstant.TEXT_XL)
            .fontColor($r('app.color.on_background'))
            .margin({ top: SizeConstant.SPACE_S })
        }
        .alignItems(HorizontalAlign.Start)

        Blank().layoutWeight(1)
        Icon({ src: $r('app.media.ic_cancel_filled') })
          .align(Alignment.TopEnd)
          .onClick(() => {
            this.files = []
          })
      }
      .alignItems(VerticalAlign.Top)

      Blank().height(SizeConstant.SPACE_M)
      List({ space: SizeConstant.SPACE_M }) {
        ForEach(this.files || [], (file: FileInfoModel) => {
          ListItem() {
            FileIcon({ fileName: file.fileName, fileType: file.fileType, bgColor: $r('app.color.container') })
          }
        }, (file: FileInfoModel, index: number) => `${file.id}_${index}`)
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .width('100%')
      .height(50)

      Blank().height(SizeConstant.SPACE_M)
      Row() {
        Button($r('app.string.edit'), { stateEffect: false, buttonStyle: ButtonStyleMode.TEXTUAL })
          .fontColor($r('app.color.on_background'))
          .onClick(() => {
            this.pages.pushPathByName(Routers.EDIT_PAGE, this.files, (info: PopInfo) => {
              this.files = info.result as ObservedArray<FileInfoModel>
            })
          })

        IconButton({
          icon: $r('app.media.ic_add_filled'),
          iconColor: Color.White,
          text: $r('app.string.append'),
          textColor: Color.White
        })
          .backgroundColor($r('app.color.primary'))
          .borderRadius(SizeConstant.RADIUS_XXL)
          .padding({
            left: SizeConstant.SPACE_XL,
            top: SizeConstant.SPACE_EXTRA_S,
            right: SizeConstant.SPACE_XL,
            bottom: SizeConstant.SPACE_EXTRA_S
          })
          .onClick(this.onAppendClick)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .alignItems(HorizontalAlign.Start)
    .padding(SizeConstant.SPACE_L)
    .borderRadius(SizeConstant.RADIUS_L)
    .backgroundColor($r('app.color.background'))
  }

  getTotalSize(): string {
    let size: number = 0
    for (const file of this.files) {
      size += file.size
    }
    return FileProvider.formatBytes(size)
  }

  addSelectFile(model: picker.DocumentSelectMode | undefined = undefined) {
    FileProvider.selectFile(this.files, model)
      .then((files: FileInfoModel[]) => {
        this.files.push(...files)
      })
      .catch((e: Error) => {
        logger.info('Send', `selected files error => ${e.message}\n${e.stack}`)
      })
  }
}