import { DialogAction, DialogHelper } from '@pura/harmony-dialog';
import { Screens, SizeConstant, toast } from 'common';
import { Icon, IconButton, NavigationTitle } from '../components';
import { FileInfoModel, ReceiveStatus } from '../model';
import { FileProvider, Routers } from '../utils';

@Component
export struct ReceivingPage {
  @Consume('pages') pages: NavPathStack;
  @State status: ReceiveStatus = new ReceiveStatus()
  @State topPadding: Length = 0
  @State bottomPadding: Length = 0

  build() {
    NavDestination() {
      NavigationTitle({ title: $r('app.string.receiving_files') }) {
        RelativeContainer() {
          Text($r('app.string.save_directory', FileProvider.getDefaultFileDir(getContext(this))))
            .width('100%')
            .fontColor($r('app.color.on_background'))
            .fontSize(SizeConstant.TEXT_XL)
            .textAlign(TextAlign.Start)
            .alignRules({
              top: { anchor: "__container__", align: VerticalAlign.Top }
            })
            .margin({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
            .padding({ top: SizeConstant.SPACE_L, bottom: SizeConstant.SPACE_L })
            .onAreaChange((_: Area, newValue: Area) => {
              this.topPadding = newValue.height
            })

          List({ space: SizeConstant.SPACE_M }) {
            ForEach(this.status?.files || [], (item: FileInfoModel) => {
              ListItem() {
                FileItem({ file: item })
              }
            }, (item: FileInfoModel, index: number) => `${item.id}_${index}`)
            ListItem().height(this.bottomPadding)
          }
          .width('100%')
          .height('100%')
          .padding({
            left: SizeConstant.SPACE_L,
            top: this.topPadding,
            right: SizeConstant.SPACE_L,
          })
          .listDirection(Axis.Vertical)

          // 底部下载进度
          Column() {
            Column() {
              Text($r('app.string.total_progress', this.getTotalProcessText()))
                .fontSize(SizeConstant.TEXT_XXL)
                .fontColor($r('app.color.on_background'))
                .width('100%')
                .textAlign(TextAlign.Start)
              Blank().height(SizeConstant.SPACE_M)
              Progress({
                value: this.status?.progress || 0,
                total: this.status?.total || 100,
                type: ProgressType.Linear
              })
                .style({ strokeWidth: 10, enableSmoothEffect: true })
                .color($r('app.color.primary'))
              Blank().height(SizeConstant.SPACE_M)
              //高级 - 取消
              Row() {
                IconButton({
                  icon: $r('app.media.ic_detail'),
                  text: $r('app.string.advanced'),
                  iconColor: $r('app.color.on_container'),
                  iconSize: SizeConstant.ICON_L,
                  arrangement: FlexDirection.Row
                })
                Blank().width(SizeConstant.SPACE_XXL)
                IconButton({
                  icon: $r('app.media.ic_cancel_filled'),
                  text: $r('app.string.cancel'),
                  iconColor: $r('app.color.on_container'),
                  iconSize: SizeConstant.ICON_L,
                  arrangement: FlexDirection.Row
                }).onClick(() => {
                  this.showCancelDialog()
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.End)
            }
            .margin({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
            .padding(SizeConstant.SPACE_L)
            // .backgroundColor($r('app.color.background'))
            .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN, {})
            .borderRadius(SizeConstant.RADIUS_L)
          }
          .alignRules({
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
          })
          .padding({ bottom: Screens.getNavigationBarHeight() })
          .onAreaChange((_: Area, newValue: Area) => {
            this.bottomPadding = newValue.height
          })
        }
        .height('100%')
        .width('100%')
        .backgroundColor($r('app.color.container'))
      }
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
    .onBackPressed(() => {
      toast.show("拦截掉！")
      this.showCancelDialog()
      return true
    })
  }

  aboutToAppear(): void {
    this.status = new ReceiveStatus()
    this.status.total = 100
    this.status.progress = 56

    const params: Array<object> = this.pages.getParamByName(Routers.RECEIVING_PAGE) as Array<object>
    if (params && params.length != 0) {
      try {
        for (const element of Object.keys(params[0])) {
          const value: FileInfoModel = params[0][element]
          this.status.files.push(value)
        }
      } catch (e) {
      }
    }
  }

  aboutToDisappear(): void {
    FileProvider.setReceivingFiles(false)
  }

  getTotalProcessText(): string {
    if (!this.status.progress) {
      return '-'
    }
    return `${(this.status.progress / this.status.total * 100).toFixed(2)}%`
  }

  showCancelDialog() {
    DialogHelper.showAlertDialog({
      title: $r('app.string.cancel_file_transfer_title'),
      content: $r('app.string.cancel_file_transfer_tips'),
      autoCancel: false,
      backCancel: false,
      alignment: DialogAlignment.Bottom,
      offset: {
        dx: 0,
        dy: -Screens.getNavigationBarHeight()
      },
      primaryButton: {
        value: $r('app.string.cancel'),
        fontColor: $r('app.color.on_container_secondary'),
      },
      secondaryButton: $r('app.string.positive'),
      onAction: (action) => {
        if (action == DialogAction.TWO) {
          // todo 发送一个中断上传消息给WebService
          this.pages.pop()
        }
      }
    })
  }
}

@Component
struct FileItem {
  @Prop file: FileInfoModel
  @State isLongPress: boolean = false

  build() {
    Row() {
      Stack() {
        Icon({
          src: FileProvider.getFileIconRes(this.file.fileName, this.file.fileType),
          iconColor: null
        })
      }
      .width(48)
      .height(48)
      .borderRadius(SizeConstant.RADIUS_L)
      .backgroundColor($r('app.color.background'))

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
        Text($r('app.string.queue'))
          .fontSize(SizeConstant.TEXT_L)
          .fontColor($r('app.color.on_container_secondary'))
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
}