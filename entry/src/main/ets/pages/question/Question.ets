import { Screens, SizeConstant } from 'common'
import { NavigationTitle } from '../../components'
import { QuestionCard } from './QuestionCard'

@Component
export struct Question {
  build() {
    NavDestination() {
      NavigationTitle({ title: $r('app.string.troubleshooting') }) {
        Scroll() {
          Column() {
            Text($r('app.string.solution_tips'))
              .fontSize(SizeConstant.TEXT_L)
              .fontColor($r('app.color.on_container'))
            Blank().height(SizeConstant.SPACE_L)
            QuestionCard({ title: $r('app.string.firewall_title'), text: $r('app.string.firewall_text') })
            Blank().height(SizeConstant.SPACE_L)
            QuestionCard({ title: $r('app.string.discover_title'), text: $r('app.string.discover_text') })
            Blank().height(SizeConstant.SPACE_L)
            QuestionCard({ title: $r('app.string.discover_two_way_title'), text: $r('app.string.discover_two_way_text') })
          }
          .justifyContent(FlexAlign.Start)
          .padding({
            left: SizeConstant.SPACE_L,
            top: SizeConstant.SPACE_L,
            right: SizeConstant.SPACE_L,
            bottom: SizeConstant.SPACE_L + Screens.getNavigationBarHeight(),
          })
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
      }
    }
    .hideTitleBar(true)
  }
}