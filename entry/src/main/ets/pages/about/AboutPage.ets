import { AppUtil } from '@pura/harmony-utils'
import { logger, SizeConstant } from 'common'
import { NavigationTitle } from '../../components'
import { common, Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Builder
export function AboutPageBuilder() {
  AboutPage()
}

const OFFICIAL_WEBSITE = 'https://localsend.org/'
const GITHUB = 'https://github.com/azhu003'
const OPENSOURCE_PROJECT = 'https://github.com/azhu003/localsend-harmony'

@Component
export struct AboutPage {
  build() {
    NavDestination() {
      NavigationTitle({ title: $r('app.string.about') }) {
        Column() {
          Blank().height(48)
          Image($r('app.media.logo'))
            .width(128)
            .height(128)
          Blank().height(SizeConstant.SPACE_XL)
          Text('LocalSend for HarmonyOS NEXT')
            .fontSize(SizeConstant.TEXT_XXL)
            .fontColor($r('app.color.on_background'))
            .fontWeight(FontWeight.Medium)
          Blank().height(SizeConstant.SPACE_S)
          Text(`Version ${AppUtil.getVersionName()}`)
            .fontSize(SizeConstant.TEXT_L)
            .fontColor($r('app.color.on_background'))
          Blank().height(SizeConstant.SPACE_XL)
          Text() {
            Span($r('app.string.official_website'))
            Span('localsend.org').fontColor($r('app.color.highlights'))
          }
          .fontSize(SizeConstant.TEXT_L)
          .copyOption(CopyOptions.LocalDevice)
          .onClick(() => this.toWeb(OFFICIAL_WEBSITE))
          //官方介绍
          Blank().height(SizeConstant.SPACE_XL)
          Text($r('app.string.about_text'))
            .fontSize(SizeConstant.TEXT_L)
            .fontColor($r('app.color.on_background'))
          //介绍
          Blank().height(SizeConstant.SPACE_L)
          Text() {
            Span('本程序是')
            Span('@Jerry·H').fontColor($r('app.color.highlights')).onClick(() => this.toWeb(GITHUB))
            Span('开发的HarmonyOS NEXT的LocalSend第三方版本，仅用于学习交流，')
            Span('非官方版本，').fontWeight(FontWeight.Medium)
            Span('您可在')
            Span('官方主页').fontColor($r('app.color.highlights')).onClick(() => this.toWeb(OFFICIAL_WEBSITE))
            Span('找到所有其他版本下载选项。')
          }
          .fontSize(SizeConstant.TEXT_L)
          //作者
          Blank().height(SizeConstant.SPACE_L)
          Text() {
            Span($r('app.string.author'))
            Span('@Jerry·H').fontColor($r('app.color.highlights'))
          }
          .fontSize(SizeConstant.TEXT_L)
          .onClick(() => this.toWeb(GITHUB))
          //开源地址
          Blank().height(SizeConstant.SPACE_L)
          Text() {
            Span($r('app.string.open_source'))
            Span(OPENSOURCE_PROJECT).fontColor($r('app.color.highlights'))
          }
          .fontSize(SizeConstant.TEXT_L)
          .copyOption(CopyOptions.LocalDevice)
          .onClick(() => this.toWeb(OPENSOURCE_PROJECT))
        }
        .alignItems(HorizontalAlign.Center)
        .padding({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
      }
    }
    .hideTitleBar(true)
  }

  toWeb(url: string) {
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url
    };
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    context.startAbility(want)
      .then(() => {
        logger.info('AboutPage', `Start browsableAbility successfully. ${url}`);
      })
      .catch((err: BusinessError) => {
        logger.error('AboutPage', `Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      });
  }
}