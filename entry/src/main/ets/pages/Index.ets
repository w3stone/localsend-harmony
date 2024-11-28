import { MainPage } from './main';
import { TransferPage } from './transfer/TransferPage';
import { Routers } from '../utils';
import { HistoryPage } from './history/HistoryPage';
import { Keys } from '../constant';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { EditorPage } from './editor';
import { DeveloperTools } from './devtools';
import { Question } from './question/Question';
import { ReceiveSetting } from './receive/ReceiveSetting';

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
    } else if (name == Routers.RECEIVE_SETTING) {
      ReceiveSetting()
    } else if (name == Routers.HISTORY) {
      HistoryPage()
    } else if (name == Routers.EDIT_PAGE) {
      EditorPage()
    } else if (name == Routers.QUESTION_PAGE) {
      Question()
    } else if (name == Routers.DEVELOPER_TOOLS) {
      DeveloperTools()
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