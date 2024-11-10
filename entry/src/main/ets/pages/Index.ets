import { MainPage } from './main';
import window from '@ohos.window';

@Entry
@Component
struct Index {
  @StorageLink("DARK_MODE") @Watch("setStatusBar") isDark: boolean = false
  @Provide('pages') pages: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pages) {
      MainPage()
    }
    .mode(NavigationMode.Auto)
    .size({ width: '100%', height: '100%' })
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'))
  }

  aboutToAppear(): void {
    this.setStatusBar()
  }

  private setStatusBar() {
    let windowStage: window.WindowStage | undefined = AppStorage.get('windowStage');
    if (windowStage != undefined) {
      let mainWin: window.Window = windowStage.getMainWindowSync();
      let props: window.SystemBarProperties = {
        // statusBarColor: (this.theme == ThemeType.DARK) ? "#111111" : "#D1D1D1",
        statusBarContentColor: this.isDark ? "#D1D1D1" : "#171717",
      };
      mainWin.setWindowSystemBarProperties(props);
    }
  }
}