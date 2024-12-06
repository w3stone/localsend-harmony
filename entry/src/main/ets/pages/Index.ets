import { MainPage } from './main';
import { TransferPage } from './transfer/TransferPage';
import { Routers } from '../utils';
import { ReceiveRecordPage } from './record/ReceiveRecordPage';
import { Keys } from '../constant';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { EditorPage } from './editor';
import { DeveloperToolsPage } from './devtools';
import { QuestionPage } from './question/QuestionPage';
import { ReceiveSettingPage } from './receive/ReceiveSettingPage';
import { SendRequestPage } from './send/SendRequestPage';
import { AnimateCallback, CustomTransition } from '../transaction';
import { JSON } from '@kit.ArkTS';
import { Objects } from 'common';

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
    } else if (name == Routers.SEND_REQUEST_PAGE) {
      SendRequestPage()
    } else if (name == Routers.TRANSFER_PAGE) {
      TransferPage()
    } else if (name == Routers.RECEIVE_SETTING_PAGE) {
      ReceiveSettingPage()
    } else if (name == Routers.HISTORY_PAGE) {
      ReceiveRecordPage()
    } else if (name == Routers.EDITOR_PAGE) {
      EditorPage()
    } else if (name == Routers.QUESTION_PAGE) {
      QuestionPage()
    } else if (name == Routers.DEVELOPER_TOOLS) {
      DeveloperToolsPage()
    }
  }

  @State isEnabled: boolean = true;
  @State isExpand: boolean = false;

  private allowedCustomTransitionFromPageNames: string[] = ['IndexPage', 'SendRequestPage'];
  private allowedCustomTransitionToPageNames: string[] = ['IndexPage', 'SendRequestPage'];

  build() {
    Navigation(this.pages) {
      MainPage()
    }
    .mode(NavigationMode.Stack)
    .size({ width: '100%', height: '100%' })
    .hideToolBar(true)
    .backgroundColor($r('app.color.container'))
    // .navDestination(this.PageParams)
    // 👇🏻 the code from Huawei. https://gitee.com/harmonyos_samples/transitions-collection.git
    .enabled(this.isEnabled)
    .customNavContentTransition((_from: NavContentInfo, _to: NavContentInfo, operation: NavigationOperation) => {
      let from: NavContentInfo
      let to: NavContentInfo
      if (_from.index == -1) {
        from = Objects.clone({}, _from)
        from.name = 'IndexPage'
        from.navDestinationId = `-1`
      } else {
        from = _from
      }
      if (_to.index == -1) {
        to = Objects.clone({}, _to)
        to.name = 'IndexPage'
        to.navDestinationId = `-1`
      } else {
        to = _to
      }
      // console.info(`customNavContentTransition from: ${JSON.stringify(from)} to: ${JSON.stringify(to)}`)
      if ((!from || !to) || (!from.name || !to.name) || (!from.navDestinationId || !to.navDestinationId)) {
        return undefined;
      }

      let fromParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(from.navDestinationId || '-1');
      let toParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(to.navDestinationId || '-1');
      CustomTransition.getInstance().operation = operation;
      // Follow the hand interaction transition.
      if (CustomTransition.getInstance().isInteractive) {
        let customAnimation: NavigationAnimatedTransition = {
          onTransitionEnd: () => {
            this.isEnabled = true;
            CustomTransition.getInstance().recoverState();
            CustomTransition.getInstance().proxy = undefined;
          },
          transition: (transitionProxy: NavigationTransitionProxy) => {
            CustomTransition.getInstance().proxy = transitionProxy;
            this.isEnabled = false;
            if (fromParam.onInteractive) {
              fromParam.onInteractive();
            }
            if (toParam.onInteractive) {
              toParam.onInteractive();
            }
          },
          isInteractive: true
        };
        return customAnimation;
      }

      // User-defined transition routes are controlled by the from and to names.
      if (!this.isCustomTransitionEnabled(from.name || 'IndexPage', to.name || 'IndexPage')) {
        return undefined;
      }

      // For the scene where button A is clicked to go to the custom transition and button B is clicked to go to the default transition,
      // it is necessary to judge whether the animation is registered to decide whether to go to the custom transition.
      // fromPage and toPage rigisterNavParam do not pass animation parameters, go to the default transition.
      if (!fromParam.animation && !toParam.animation) {
        return undefined;
      }

      // After all judgments are completed, construct customAnimation to the system side call, execute the custom transition animation.
      let customAnimation: NavigationAnimatedTransition = {
        onTransitionEnd: (isSuccess: boolean) => {
          console.info('Index', `current transition result is ${isSuccess}`);
          this.isEnabled = true;
        },
        timeout: 1000,
        transition: (transitionProxy: NavigationTransitionProxy) => {
          this.isEnabled = false;
          if (fromParam.animation) {
            fromParam.animation(transitionProxy);
          }
          if (toParam.animation) {
            toParam.animation(transitionProxy);
          }
        }
      };
      return customAnimation;
    })
  }

  private isCustomTransitionEnabled(fromName: string, toName: string): boolean {
    // Both click and return require custom transitions, so they need to be judged separately.
    if ((this.allowedCustomTransitionFromPageNames.includes(fromName)
      && this.allowedCustomTransitionToPageNames.includes(toName))
      || (this.allowedCustomTransitionFromPageNames.includes(toName)
        && this.allowedCustomTransitionToPageNames.includes(fromName))) {
      return true;
    }
    return false;
  }

  onBackPress(): boolean | void {
    this.pages.pop()
  }

  onColorModelChanged() {
    getContext(this).getApplicationContext().setColorMode(this.colorMode);
  }
}