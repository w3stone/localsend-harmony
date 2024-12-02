import { Screens, SizeConstant } from 'common'
import { NavigationTitle } from '../../components'
import { FileInfoModel, PrepareUploadModel, ReceivedFileModel } from '../../model'
import { Dates, FileProvider, mime, ObservedArray, Routers } from '../../utils'
import { ReceiveItem } from './ReceiveItem'
import { util } from '@kit.ArkTS'
import { RandomUtil } from '@pura/harmony-utils'

@Builder
export function ReceiveSettingPageBuilder() {
  ReceiveSettingPage()
}

@Component
export struct ReceiveSettingPage {
  @Consume('pages') pages: NavPathStack;
  @State files: ObservedArray<ReceivedFileModel> = new ObservedArray()

  build() {
    NavDestination() {
      NavigationTitle({ title: $r('app.string.setting') }) {
        List({ space: SizeConstant.SPACE_M }) {
          ForEach(this.files, (item: FileInfoModel) => {
            ListItem() {
              ReceiveItem({ file: item })
            }
          }, (item: FileInfoModel, index: number) => `${item.id}_${index}`)
          ListItem().height(Screens.getNavigationBarHeight())
        }
        .padding(SizeConstant.SPACE_L)
        .width('100%')
        .height('100%')
      }
    }
    .hideTitleBar(true)
  }

  aboutToAppear(): void {
    const params: Array<PrepareUploadModel> = this.pages.getParamByName(Routers.RECEIVE_SETTING_PAGE) as Array<PrepareUploadModel>
    if (params && params.length != 0) {
      // this.param = params[0]
    }
    for (let i = 0; i < 40; i++) {
      this.files.push({
        id: util.generateRandomUUID(),
        fileName: 'ic_add_filled.svg',
        size: RandomUtil.getRandomInt(10, 100000),
        fileType: mime.getType('ic_add_filled.svg') || '',
        filePath: FileProvider.getDefaultFileDir(getContext(this)),
        sender: '巨大的蓝莓',
        sendAt: Dates.now()
      })
    }
  }
}