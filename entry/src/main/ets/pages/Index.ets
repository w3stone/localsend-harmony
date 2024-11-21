import { MainPage } from './main';
import { TransferPage } from './transfer/TransferPage';
import { Routers } from '../utils';
import { HistoryPage } from './history/HistoryPage';
import { Keys } from '../constant';
import { ConfigurationConstant } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @StorageProp(Keys.COLOR_MODE)
  @Watch("onColorModelChanged")
  colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  @Provide('pages') pages: NavPathStack = new NavPathStack()

  @Builder
  PageParams(name: string) {
    if (name == Routers.INDEX) {
      Index()
    } else if (name == Routers.TRANSFER_PAGE) {
      TransferPage()
    } else if (name == Routers.HISTORY) {
      HistoryPage()
    }
  }

  build() {
    Navigation(this.pages) {
      MainPage()
    }
    .mode(NavigationMode.Stack)
    .size({ width: '100%', height: '100%' })
    .hideToolBar(true)
    .backgroundColor($r('app.color.container'))
    .navDestination(this.PageParams)
  }

  onBackPress(): boolean | void {
    this.pages.pop()
  }

  onColorModelChanged() {
    getContext(this).getApplicationContext().setColorMode(this.colorMode);
  }
}