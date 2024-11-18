import { MainPage } from './main';
import window from '@ohos.window';
import { TransferPage } from './transfer/TransferPage';
import { Routers } from '../utils';
import { ThemeControl } from '@kit.ArkUI';
import { DefaultThemes } from '../theme/DefaultColors';

@Entry
@Component
struct Index {
  @StorageLink("DARK_MODE") @Watch("setStatusBar") isDark: boolean = false
  @Provide('pages') pages: NavPathStack = new NavPathStack()

  @Builder
  PageParams(name: string) {
    if (name == Routers.TRANSFER_PAGE) {
      TransferPage()
    } else if (name == Routers.INDEX) {
      Index()
    }
  }

  build() {
    Navigation(this.pages) {
      MainPage()
    }
    .mode(NavigationMode.Auto)
    .size({ width: '100%', height: '100%' })
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'))
    .navDestination(this.PageParams)
  }

  aboutToAppear(): void {
    this.setStatusBar()
    this.initTheme()
  }

  onBackPress(): boolean | void {
    this.pages.pop()
  }

  private setStatusBar() {
    let windowStage: window.WindowStage | undefined = AppStorage.get('windowStage');
    if (windowStage != undefined) {
      let mainWin: window.Window = windowStage.getMainWindowSync();
      let props: window.SystemBarProperties = {
        statusBarContentColor: this.isDark ? "#D1D1D1" : "#171717",
      };
      mainWin.setWindowSystemBarProperties(props);
    }
  }

  private initTheme() {
    ThemeControl.setDefaultTheme(new DefaultThemes())
  }
}