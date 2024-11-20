import { SizeConstant } from 'common/src/main/ets/constant/SizeConstant'
import { NavigationTitle } from '../../components'
import { ReceivedFileModel } from '../../model'
import { HistoryItem } from './HistoryItem'
import { util } from '@kit.ArkTS'
import { mime } from 'serve'
import { RandomUtil } from '@pura/harmony-utils'
import { Dates, DeviceProvider, FileProvider } from '../../utils'
import { Screens } from 'common'

@Component
export struct HistoryPage {
  @State data: ReceivedFileModel[] = []

  build() {
    NavDestination() {
      NavigationTitle({ title: $r('app.string.history') }) {
        List({ space: SizeConstant.SPACE_L }) {
          ForEach(this.data, (item: ReceivedFileModel, index: number) => {
            ListItem() {
              HistoryItem({ data: item, index: index })
            }
          }, (item: ReceivedFileModel, index: number) => `${item.id}_${index}`)
          ListItem().height(Screens.getNavigationBarHeight())
        }
        .width('100%')
        .height('100%')
        .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
        .listDirection(Axis.Vertical)
      }
    }
    .hideTitleBar(true)
  }

  aboutToAppear(): void {
    for (let i = 0; i < 40; i++) {
      this.data.push({
        id: util.generateRandomUUID(),
        fileName: 'ic_add_filled.svg',
        size: RandomUtil.getRandomInt(10, 100000),
        fileType: mime.getType('ic_add_filled.svg') || '',
        sender: DeviceProvider.getRandomAlias(getContext(this).resourceManager),
        sendAt: Dates.now(),
        filePath: FileProvider.getDefaultFileDir(getContext(this))
      })
    }
  }
}