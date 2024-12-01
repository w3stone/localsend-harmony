// 窗口信息
import { window } from '@kit.ArkUI';

export class WindowUtils {
  public static window: window.Window;
  public static windowWidth_px: number;
  public static windowHeight_px: number;
  public static topAvoidAreaHeight_px: number;
  public static navigationIndicatorHeight_px: number;

  static onWindowStageCreate(windowStage: window.WindowStage){
    // 获取窗口宽高
    WindowUtils.window = windowStage.getMainWindowSync();
    WindowUtils.windowWidth_px = WindowUtils.window.getWindowProperties().windowRect.width;
    WindowUtils.windowHeight_px = WindowUtils.window.getWindowProperties().windowRect.height;

    // 获取上方避让区(状态栏等)高度
    let avoidArea = WindowUtils.window.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    WindowUtils.topAvoidAreaHeight_px = avoidArea.topRect.height;

    // 获取导航条高度
    let navigationArea = WindowUtils.window.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    WindowUtils.navigationIndicatorHeight_px = navigationArea.bottomRect.height;

    // 监听窗口尺寸、状态栏高度及导航条高度的变化并更新
    try {
      WindowUtils.window.on('windowSizeChange', (data) => {
        WindowUtils.windowWidth_px = data.width;
        WindowUtils.windowHeight_px = data.height;
        AppStorage.setOrCreate('windowSizeChanged', Date.now())
      })

      WindowUtils.window.on('avoidAreaChange', (data) => {
        if (data.type == window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height;
          WindowUtils.topAvoidAreaHeight_px = topRectHeight;
        } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottomRectHeight = data.area.bottomRect.height;
          WindowUtils.navigationIndicatorHeight_px = bottomRectHeight;
        }
      })
    } catch (exception) {
      console.log('register failed ' + JSON.stringify(exception));
    }
  }
}