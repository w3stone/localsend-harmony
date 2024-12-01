import { Screens, SizeConstant } from 'common';
import { NavigationTitle } from '../../components';
import { FileInfoModel } from '../../model';
import { FileProvider, ObservedArray, Routers } from '../../utils';
import { EditorItem } from './EditorItem';

@Builder
export function EditorPageBuilder() {
  EditorPage()
}

@Component
export struct EditorPage {
  @Consume('pages') pages: NavPathStack
  @State files: ObservedArray<FileInfoModel> = []

  build() {
    NavDestination() {
      NavigationTitle({ title: $r('app.string.select') }) {
        Column() {
          Blank().height(SizeConstant.SPACE_M)
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
            Button($r('app.string.delete_all'))
              .onClick(() => {
                this.files = []
                this.pages.pop(this.files)
              })
          }

          List({ space: SizeConstant.SPACE_M }) {
            ForEach(this.files, (item: FileInfoModel, index: number) => {
              ListItem() {
                EditorItem({
                  file: item, onChanged: (newFile: FileInfoModel | null) => {
                    this.onFileItemChanged(newFile, index)
                  }
                })
              }
            }, (item: FileInfoModel, index: number) => `${item.id}_${index}`)
            ListItem().height(Screens.getNavigationBarHeight())
          }
          .width('100%')
          .height('100%')
          .listDirection(Axis.Vertical)
          .padding({ top: Screens.getStatusBarHeight(), bottom: Screens.getNavigationBarHeight() })
        }
        .width('100%')
        .height('100%')
        .padding(SizeConstant.SPACE_L)
      }
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      // NavPathStack.pushPathByName 回调函数会先于onBackPressed执行
      // 这里先拦截返回事件，再延迟10ms手动调用pop返回修改后的参数
      setTimeout(() => {
        this.pages.pop(this.files)
      }, 10)
      return true
    })
  }

  aboutToAppear(): void {
    const params: Array<ObservedArray<FileInfoModel>> =
      this.pages.getParamByName(Routers.EDITOR_PAGE) as Array<ObservedArray<FileInfoModel>>
    this.files = params[0]
  }

  onFileItemChanged(newFile: FileInfoModel | null, index: number) {
    if (newFile == null) {
      this.files.splice(index, 1)
      //全部都删完后退出
      if (this.files.length === 0) {
        this.pages.pop(this.files)
      }
    } else {
      this.files[index] = newFile
    }
  }

  getTotalSize(): string {
    let size: number = 0
    for (const file of this.files) {
      size += file.size
    }
    return FileProvider.formatBytes(size)
  }
}