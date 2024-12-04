import { DeviceModel, FileInfoModel, NearbyDeviceModel, PrepareTransferModel, TransferPageParam } from '../../model'
import { DeviceProvider, Routers } from '../../utils'
import { Errors, logger, Screens, SizeConstant } from 'common'
import { DialogAction, DialogHelper } from '@pura/harmony-dialog'
import { WebClient } from '../../service'
import { HttpRequestError, Terminator } from '../../http'
import { DeviceItem, Icon, IconButton } from '../../components'
import { SendRequestParams } from '.'
import { CustomTransition, LongTakeAnimationProperties } from '../../transaction'
import { SnapShotImage } from '../../transaction/SnapShotImage'

@Builder
export function SendRequestPageBuilder() {
  SendRequestPage()
}

@Component
export struct SendRequestPage {
  @Consume('pages') pages: NavPathStack
  @State files: FileInfoModel[] = []
  @State target: NearbyDeviceModel | null = null
  @State current: DeviceModel = DeviceProvider.getCurrentDevice()
  @State message: ResourceStr = $r('app.string.waiting_response')
  @State isComplete: boolean = false
  @State sessionId: string = ''
  @State terminate: Terminator | null = null
  @State pin: string = ''
  @State isInvalidPin: boolean = false
  //动画执行完成
  @State isInteractive: boolean = true
  private pageId: string | undefined = '';
  private clickedItemId?: string = '';
  private shouldDoDefaultTransition: boolean = false;
  private prePageDoFinishTransition?: VoidCallback
  @State snapShotImage: PixelMap | undefined = SnapShotImage.pixelMap;
  @State longTakeAnimationProperties: LongTakeAnimationProperties = new LongTakeAnimationProperties();

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Stack({ alignContent: Alignment.TopStart }) {
          // Used to display a screenshot of the card clicked on the previous page.
          Column() {
            Image(this.snapShotImage)
              .size(this.longTakeAnimationProperties.snapShotSize)
              .width('100%')
              .objectFit(ImageFit.Auto)
              .syncLoad(true)
          }
          .opacity(this.longTakeAnimationProperties.snapShotOpacity)
          .padding({
            left: SizeConstant.SPACE_XL,
            right: SizeConstant.SPACE_XL,
          })

          if (this.isInteractive) {
            Column() {
              Blank().height(Screens.getStatusBarHeight() + SizeConstant.SPACE_XL)

              if (this.current) {
                DeviceItem({ device: this.current, favorDisplay: false })
                  .transition(
                    TransitionEffect.OPACITY.animation({ duration: 500, delay: 50 })
                      .combine(TransitionEffect.translate({ y: -1000 }).animation({ duration: 500, delay: 50 }))
                  )
              }

              Icon({ src: $r('app.media.ic_down'), iconColor: $r('app.color.on_container') })
                .margin({ top: SizeConstant.SPACE_L, bottom: SizeConstant.SPACE_L })
                .transition(TransitionEffect.OPACITY.animation({ duration: 800, delay: 350 }))
              // .opacity(this.longTakeAnimationProperties.postPageOpacity)

              DeviceItem({ device: this.target, favorDisplay: false })
                .id(this.clickedItemId)// .opacity(this.longTakeAnimationProperties.postPageOpacity)
                .translate({
                  x: this.longTakeAnimationProperties.translateX,
                  y: this.longTakeAnimationProperties.translateY
                })

              Column() {
                Blank().layoutWeight(1)
                Text(this.message).fontSize(SizeConstant.TEXT_L).fontColor($r('app.color.warn'))
                Blank().height(SizeConstant.SPACE_L)

                IconButton({
                  icon: this.isComplete ? $r('app.media.ic_todo_filled') : $r('app.media.ic_cancel_filled'),
                  iconColor: Color.White,
                  text: this.isComplete ? $r('app.string.close') : $r('app.string.cancel'),
                  textColor: Color.White
                })
                  .padding({
                    left: SizeConstant.SPACE_XL,
                    top: SizeConstant.SPACE_EXTRA_S,
                    right: SizeConstant.SPACE_XL,
                    bottom: SizeConstant.SPACE_EXTRA_S
                  })
                  .backgroundColor($r('app.color.primary'))
                  .borderRadius(SizeConstant.RADIUS_L)
                  .onClick(() => {
                    if (!this.isComplete && this.target && this.sessionId) {
                      WebClient.cancel(this.target, this.sessionId)
                    }
                    this.onBackPress()
                  })
                Blank().height(SizeConstant.SPACE_L)
              }
              .layoutWeight(1)
              .transition(TransitionEffect.OPACITY.animation({ duration: 350, delay: 350 }))
            }
            .padding(SizeConstant.SPACE_L)
            .opacity(this.longTakeAnimationProperties.postPageOpacity)
          }
        }
      }
      //动画相关
      .translate({
        x: this.longTakeAnimationProperties.translateX,
        y: this.longTakeAnimationProperties.translateY
      })
      .width(this.longTakeAnimationProperties.clipWidth)
      .height(this.longTakeAnimationProperties.clipHeight)
    }
    .hideTitleBar(true)
    .backgroundColor(this.longTakeAnimationProperties.navDestinationBgColor)
    .onReady((context: NavDestinationContext) => {
      const param = context.pathInfo.param as SendRequestParams
      if (param && param.files.length != 0) {
        this.files = param.files
        this.target = param.target
        //动画参数
        let clickedCardId = param.id
        this.prePageDoFinishTransition = param.doDefaultTransition
        if (context.navDestinationId && clickedCardId) {
          this.pageId = context.navDestinationId;
          this.clickedItemId = clickedCardId;
          this.tryRegisterCustomTransition(clickedCardId);
        }
        this.sendPrepareUpload()
      } else {
        this.pages.pop(false)
      }
    })
    .onBackPressed(() => {
      return this.onBackPress()
      return true;
    })
    .onDisAppear(() => {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId || '');
    })
  }

  unRegisterNavParam(): void {
    this.shouldDoDefaultTransition = true;
  }

  onBackPress(): boolean {
    // this.getUIContext().animateTo({ curve: Curve.Friction }, () => this.pages.pop(false))
    if (this.shouldDoDefaultTransition) {
      CustomTransition.getInstance().unRegisterNavParam(this.pageId || '');
      this.pages.pop();
      if (this.prePageDoFinishTransition) {
        this.prePageDoFinishTransition()
      }
      this.shouldDoDefaultTransition = false;
      return true;
    }
    this.pages.pop();
    return false
  }

  // aboutToAppear(): void {
  //   const params = this.pages.getParamByName(Routers.SEND_REQUEST_PAGE) as Array<SendRequestParams>
  //   if (params && params.length != 0) {
  //     const param: SendRequestParams = params[0]
  //     this.files = param.files
  //     this.target = param.target
  //     this.geometryId = param.geometryId
  //     this.sendPrepareUpload()
  //   } else {
  //     this.pages.pop(false)
  //   }
  // }

  aboutToDisappear(): void {
    this.isComplete = true
    this.terminate?.terminate()
  }

  // Try to register a custom transition animation to restore the page properties to their normal state in case of an exception.
  tryRegisterCustomTransition(clickedCardId: string): void {
    try {
      // First initialize some transition information.
      this.longTakeAnimationProperties.init(clickedCardId, this.prePageDoFinishTransition || (() => {
      }));
      CustomTransition.getInstance().registerNavParam(this.pageId || '', 0, (transitionProxy: NavigationTransitionProxy) => {
        if (CustomTransition.getInstance().operation === NavigationOperation.PUSH) {
          this.isInteractive = true
        } else {
          this.isInteractive = false
        }
        console.info(`this.isInteractive: ${this.isInteractive}`)
        this.longTakeAnimationProperties.doAnimation(transitionProxy);
      });
      logger.info('SendRequestPage', 'CardLongTakePageTwo register successes');
    } catch (error) {
      logger.info('SendRequestPage', 'CardLongTakePageTwo this is error ' + error);
      this.longTakeAnimationProperties.setFinalStatus();
    }
  }

  sendPrepareUpload() {
    if (this.target && this.files.length > 0) {
      WebClient.prepareUpload(this.target, this.files, this.pin, (terminate: Terminator) => this.terminate = terminate)
        .then((result: PrepareTransferModel) => {
          this.sessionId = result.sessionId
          const parma = new TransferPageParam(true, this.files)
          parma.sessionId = result.sessionId
          parma.target = [this.target!!]
          parma.fileToken = result.files
          this.pages.replacePath({ name: Routers.TRANSFER_PAGE, param: parma })
        })
        .catch((reason: object) => {
          if (reason instanceof HttpRequestError) {
            if (reason.status === 401) {
              if (this.pin) {
                this.isInvalidPin = true
              }
              DialogHelper.showTextInputDialog({
                title: $r('app.string.enter_pin'),
                text: '',
                secondaryTitle: this.isInvalidPin ? $r('app.string.invalid_pin') : '',
                inputBorder: { radius: SizeConstant.RADIUS_M },
                onAction: (action: DialogAction, _: string, content: string) => {
                  if (action === DialogAction.ONE) {
                    this.isComplete = true
                    this.message = ''
                  } else if (action === DialogAction.TWO) {
                    if (this.pin != content) {
                      this.pin = content
                      this.sendPrepareUpload()
                    }
                  }
                },
                onDidDisappear: () => this.isInvalidPin = false
              })
            } else if (reason.status === 403) {
              this.message = $r('app.string.otherside_refused_the_request')
            } else if (reason.status === 409) {
              this.message = $r('app.string.otherside_processing_other_requests')
            } else if (reason.status === 429) {
              this.message = $r('app.string.too_many_requests')
            } else {
              this.message = $r('app.string.error')
            }
          } else {
            this.message = $r('app.string.error')
          }
          this.isComplete = true
          logger.info('SendRequestDialog', `返回错误: ${Errors.getErrorMessage(reason)}`)
        })
    }
  }
}