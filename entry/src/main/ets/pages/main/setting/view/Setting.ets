import { SizeConstant } from 'common';
import { NavigationTitle, SpinnerButton } from '../../../../components';
import { SettingItem } from './SettingItem';
import { Keys } from '../../../../constant';
import { ThemeProvider } from '../../../../theme/ThemeProvider';
import { ThemeMenu } from './ThemeMenu';
import { ConfigurationConstant } from '@kit.AbilityKit';

@Component
export struct Setting {
  @State uuid: string = ''
  @Consume('pages') pages: NavPathStack;
  @State isShowingServiceInfo: boolean = false
  @StorageProp(Keys.COLOR_MODE)
  @Watch('onColorModeChanged')
  colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET

  onColorModeChanged() {
    console.info(`onColorModeChanged ->> ${this.colorMode}`)
  }

  build() {
    // 卡片折叠态，展开态的共同父组件
    Stack() {
      NavigationTitle({
        title: $r('app.string.select'),
        isHideBackButton: true,
        // titleBackgroundColor: $r('app.color.background')
      }) {
        Scroll() {
          Column() {
            //通用设置
            Column() {
              Text($r('app.string.universal'))
                .fontSize(SizeConstant.TEXT_XXL)
                .fontColor($r('app.color.on_background'))
                .padding(SizeConstant.SPACE_M)
              SettingItem({ text: $r('app.string.theme') }) {
                SpinnerButton({ text: ThemeProvider.getThemeModelText(this.colorMode) }).bindMenu(ThemeMenu)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .padding(SizeConstant.SPACE_M)
            .backgroundColor($r('app.color.container'))
            .borderRadius(SizeConstant.RADIUS_L)

            Blank().height(SizeConstant.SPACE_L)

            //接收
            Column() {
              Text($r('app.string.receive'))
                .fontSize(SizeConstant.TEXT_XXL)
                .fontColor($r('app.color.on_background'))
                .padding(SizeConstant.SPACE_M)
              SettingItem({ text: $r('app.string.auto_save') }) {
                Toggle({ type: ToggleType.Switch, isOn: true })
              }

              SettingItem({ text: $r('app.string.auto_save_favorites_title') }) {
                Toggle({ type: ToggleType.Switch, isOn: true })
              }

              SettingItem({ text: $r('app.string.use_pin') }) {
                Toggle({ type: ToggleType.Switch, isOn: true })
              }

              SettingItem({ text: $r('app.string.aut_complete') }) {
                Toggle({ type: ToggleType.Switch, isOn: true })
              }

              SettingItem({ text: $r('app.string.save_to_history') }) {
                Toggle({ type: ToggleType.Switch, isOn: true })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .padding(SizeConstant.SPACE_M)
            .backgroundColor($r('app.color.container'))
            .borderRadius(SizeConstant.RADIUS_L)

            Blank().height(SizeConstant.SPACE_L)

            //发送
            Column() {
              Text($r('app.string.send'))
                .fontSize(SizeConstant.TEXT_XXL)
                .fontColor($r('app.color.on_background'))
                .padding(SizeConstant.SPACE_M)
              SettingItem({ text: $r('app.string.auto_receive_link_sharing') }) {
                Toggle({ type: ToggleType.Switch, isOn: true })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .padding(SizeConstant.SPACE_M)
            .backgroundColor($r('app.color.container'))
            .borderRadius(SizeConstant.RADIUS_L)

            Blank().height(SizeConstant.SPACE_L)

            //网络
            Column() {
              Text($r('app.string.network'))
                .fontSize(SizeConstant.TEXT_XXL)
                .fontColor($r('app.color.on_background'))
                .padding(SizeConstant.SPACE_M)
              SettingItem({ text: $r('app.string.theme') }) {
                Toggle({ type: ToggleType.Switch, isOn: true })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .padding(SizeConstant.SPACE_M)
            .backgroundColor($r('app.color.container'))
            .borderRadius(SizeConstant.RADIUS_L)

            Blank().height(SizeConstant.SPACE_L)

            //其他
            Column() {
              Text($r('app.string.other'))
                .fontSize(SizeConstant.TEXT_XXL)
                .fontColor($r('app.color.on_background'))
                .padding(SizeConstant.SPACE_M)
              SettingItem({ text: $r('app.string.theme') }) {
                Toggle({ type: ToggleType.Switch, isOn: true })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .padding(SizeConstant.SPACE_M)
            .backgroundColor($r('app.color.container'))
            .borderRadius(SizeConstant.RADIUS_L)
          }
          .constraintSize({ minHeight: '100%' })
          .padding(SizeConstant.SPACE_L)
        }
        .width('100%')
        .height('100%')
      }
    }
  }
}