import { logger, SizeConstant, toast } from 'common';
import { Icon, NavigationTitle, SendRequestDialog } from '../../../../components';
import { DeviceModel } from '../../../../model/DeviceModel';
import { DeviceProvider } from '../../../../utils/DeviceProvider';
import { EventBus, EventType } from '../../../../eventbus';
import { SelectorButton } from './SelectorButton';
import { DeviceItem } from '../../../../components/DeviceItem';
import { picker } from '@kit.CoreFileKit';
import { SelectedFiles } from './SelctedFiles';
import { FileProvider, ObservedArray } from '../../../../utils';
import { FileInfoModel } from '../../../../model';
import { DialogAction, DialogHelper } from '@pura/harmony-dialog';
import { JSON } from '@kit.ArkTS';

@Component
export struct Send {
  @StorageLink(DeviceProvider.REGISTERED_DEVICE_LIST_KEY) allDevice: DeviceModel[] = []
  @State selectedFiles: ObservedArray<FileInfoModel> = []
  @State send: ObservedArray<FileInfoModel> = []
  @State toDevice: DeviceModel | null = null
  mSendFileRequestDialog: CustomDialogController | null = new CustomDialogController({
    width: '100%',
    height: '100%',
    offset: {
      dx: 0,
      dy: 0
    },
    builder: SendRequestDialog({
      files: this.selectedFiles,
      target: this.toDevice,
    }),
  })

  build() {
    NavigationTitle({ title: $r('app.string.select'), isHideBackButton: true }) {
      Column() {
        if (this.selectedFiles && this.selectedFiles.length > 0) {
          SelectedFiles({
            files: this.selectedFiles,
            onCloseClick: () => {
              toast.show('clear')
              this.selectedFiles = []
            },
            onEditClick: () => {

            },
            onAppendClick: () => {
              this.addSelectFile()
            }
          })
        } else {
          Row() {
            SelectorButton({ text: $r('app.string.file'), icon: $r('app.media.ic_file') })
              .layoutWeight(1)
              .onClick(() => {
                this.addSelectFile()
              })
            Blank().width(SizeConstant.SPACE_M)
            if (canIUse('SystemCapability.FileManagement.UserFileService.FolderSelection')) {
              SelectorButton({ text: $r('app.string.folder'), icon: $r('app.media.ic_folder_filled') })
                .layoutWeight(1)
                .onClick(() => {
                  this.addSelectFile(picker.DocumentSelectMode.FOLDER)
                })
              Blank().width(SizeConstant.SPACE_M)
            }
            SelectorButton({ text: $r('app.string.text'), icon: $r('app.media.ic_text_filled') })
              .layoutWeight(1)
              .onClick(() => {
                this.onSendTextMessageClick()
              })
            Blank().width(SizeConstant.SPACE_M)
            SelectorButton({ text: $r('app.string.clipboard'), icon: $r('app.media.ic_clipboard') })
              .layoutWeight(1)
              .onClick(() => {
                toast.show("发送文件")
              })
          }
          .width('100%')
        }

        //附近设备
        Row() {
          Text($r('app.string.nearby_devices'))
            .fontSize(SizeConstant.TEXT_XXL)
            .fontColor($r('app.color.on_container'))
          Blank().width(SizeConstant.SPACE_L)
          Icon({
            src: $r('app.media.ic_rotate'),
            spacing: SizeConstant.SPACE_EXTRA_S,
          }).onClick(() => {
            this.allDevice = []
            EventBus.getInstance().post(EventType.SCAN_DEVICE)
          })
          Blank().width(SizeConstant.SPACE_L)
          Icon({
            src: $r('app.media.ic_quickstart'),
            spacing: SizeConstant.SPACE_EXTRA_S,
          }).onClick(() => {
            toast.show("手动发送")
          })
          Blank().width(SizeConstant.SPACE_L)
          Icon({
            src: $r('app.media.ic_favor'), spacing: SizeConstant.SPACE_EXTRA_S,
          }).onClick(() => {
            toast.show("收藏夹")
          })
          Blank().width(SizeConstant.SPACE_L)
          Icon({
            src: $r('app.media.ic_settings'), spacing: SizeConstant.SPACE_EXTRA_S,
          }).onClick(() => {
            toast.show("发送模式")
          })
        }
        .margin({ top: SizeConstant.SPACE_XL })

        //设备列表
        if (this.allDevice.length > 0) {
          List() {
            ForEach(
              this.allDevice,
              (item: DeviceModel) => {
                ListItem() {
                  DeviceItem({ device: item })
                    .onClick(() => {
                      if (!this.selectedFiles || this.selectedFiles.length == 0) {
                        DialogHelper.showAlertDialog({
                          title: $r('app.string.unselected_file'),
                          content: $r('app.string.unselected_file_text'),
                          secondaryButton: $r('app.string.close'),
                          onAction: () => {
                          },
                        })
                      } else {
                        this.toDevice = item
                        this.mSendFileRequestDialog?.open()
                      }
                    })
                }
              },
              (item: DeviceModel, index: number) => `${item.key}_${index}`
            )
          }
          .listDirection(Axis.Vertical)
          .width('100%')
          .layoutWeight(1)
        } else {
          DeviceItem()
        }
      }
      .alignItems(HorizontalAlign.Start)
      .size({ width: '100%', height: '100%' })
      .padding({
        right: SizeConstant.SPACE_L,
        left: SizeConstant.SPACE_L
      })
    }
  }

  addSelectFile(model: picker.DocumentSelectMode | undefined = undefined) {
    FileProvider.selectFile(this.selectedFiles, model)
      .then((files: FileInfoModel[]) => {
        this.selectedFiles.push(...files)
      })
      .catch((e: Error) => {
        logger.info('Send', `selected files error => ${e.message}\n${e.stack}`)
      })
  }

  onSendTextMessageClick() {
    DialogHelper.showTextAreaDialog({
      title: $r('app.string.enter_message'),
      text: '',
      inputBorder: {
        radius: SizeConstant.RADIUS_M
      },
      onAction: (action: DialogAction, _: string, content: string) => {
        if (action == DialogAction.TWO) {
          this.selectedFiles.push(...FileProvider.createTextMessages(content))
          logger.info('Send', `selected: ${JSON.stringify(this.selectedFiles)}`)
        }
      }
    })
  }
}