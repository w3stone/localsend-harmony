import { DialogHelper } from '@pura/harmony-dialog';
import { common } from '@kit.AbilityKit';

export class DialogProvider {
  private constructor() {
  }

  static init(context: common.UIAbilityContext | UIContext) {
    //设置默认的统一配置，在UIAbility的onCreate方法里初始化
    DialogHelper.setDefaultConfig((config) => {
      config.uiContext = context //必须初始化上下文
      config.alignment = DialogAlignment.Center; //弹窗的对齐方式。
      config.maskColor = 0x33000000; //自定义蒙层颜色。默认值 0x33000000
      config.backgroundColor = $r('app.color.container'); //弹窗背板颜色。默认值：Color.White
      // config.backgroundBlurStyle = BlurStyle.COMPONENT_ULTRA_THICK; //弹窗背板模糊材质。默认值：BlurStyle.COMPONENT_ULTRA_THICK
      config.cornerRadius = 20; //设置背板的圆角半径。可分别设置4个圆角的半径。

      config.title = ''; //弹框标题
      config.primaryButton = $r('app.string.cancel'); //弹框左侧按钮。
      config.secondaryButton = $r('app.string.positive'); //弹框右侧按钮。
      config.imageRes = undefined; //TipsDialog用到，展示的图片。
      config.imageSize = { width: '64vp', height: '64vp' }; //TipsDialog用到，自定义图片尺寸。默认值：64*64vp

      config.loading_loadSize = 60; //加载动画或进度条的大小
      config.loading_loadColor = Color.White; //加载动画或进度条的颜色
      config.loading_content = ''; //加载动画的提示文字
      config.loading_fontSize = 16; //文字大小
      config.loading_fontColor = Color.White; //文字颜色
      config.loading_backgroundColor = '#CC000000'; //背景颜色，八位色值前两位为透明度
      config.loading_borderRadius = 10; //背景圆角

      config.toast_fontSize = 16; //文字大小
      config.toast_fontColor = Color.White; //文字颜色
      config.toast_backgroundColor = '#CC000000'; //背景颜色，建议八位色值前两位为透明度
      config.toast_borderRadius = 8; //背景圆角
      config.toast_padding = {
        left: 16,
        right: 16,
        top: 12,
        bottom: 12
      }; //Padding
      config.toast_imageSize = { width: 45, height: 45 }; //Tip图片尺寸。默认值：45*45vp
      config.toast_duration = 2000; //显示时长(1500ms-10000ms)
      config.toast_durationLong = 10000; //显示时长(10000ms)
    });
  }
}