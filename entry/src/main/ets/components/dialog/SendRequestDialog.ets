import { DeviceModel, FileInfoModel, PrepareTransferModel, TransferPageParam } from '../../model'
import { DeviceItem, Icon, IconButton } from '..'
import { DeviceProvider, Routers } from '../../utils'
import { Errors, logger, SizeConstant } from 'common'
import { AnimationHelper, DialogAction, DialogHelper } from '@pura/harmony-dialog'
import { WebClient } from '../../service/WebClient'
import { HttpRequestError, Terminator } from '../../http'

@CustomDialog
export struct SendRequestDialog {
  controller: CustomDialogController
  @Consume('pages') pages: NavPathStack
  @Prop files: FileInfoModel[] = []
  @Prop target: DeviceModel | null
  @State current: DeviceModel = DeviceProvider.getCurrentDevice()
  @State message: ResourceStr = $r('app.string.waiting_response')
  @State isComplete: boolean = false
  @State sessionId: string = ''
  @State terminate: Terminator | null = null
  @State pin: string = ''
  @State isInvalidPin: boolean = false

  build() {
    Column() {
      if (this.current) {
        DeviceItem({ device: this.current, favorDisplay: false })
          .transition(TransitionEffect.OPACITY.animation({ duration: 500 }).combine(AnimationHelper.transitionInUp(300)))
      }

      Icon({ src: $r('app.media.ic_down'), iconColor: $r('app.color.on_container') })
        .margin({ top: SizeConstant.SPACE_L, bottom: SizeConstant.SPACE_L })
        .transition(TransitionEffect.OPACITY.animation({ duration: 800 }))

      if (this.target) {
        DeviceItem({ device: this.target, favorDisplay: false })
          .transition(TransitionEffect.OPACITY.animation({ duration: 500 }).combine(AnimationHelper.transitionInDown(300)))
      }

      Blank().layoutWeight(1)
      Text(this.message).fontSize(SizeConstant.TEXT_L).fontColor($r('app.color.warn'))
      Blank().height(SizeConstant.SPACE_L)

      IconButton({
        icon: this.isComplete ? $r('app.media.ic_todo_filled') : $r('app.media.ic_cancel_filled'),
        iconColor: Color.White,
        text: this.isComplete ? $r('app.string.close') : $r('app.string.cancel'),
        textColor: Color.White
      }).padding({
        left: SizeConstant.SPACE_XL,
        top: SizeConstant.SPACE_EXTRA_S,
        right: SizeConstant.SPACE_XL,
        bottom: SizeConstant.SPACE_EXTRA_S
      }).backgroundColor($r('app.color.primary'))
        .borderRadius(SizeConstant.RADIUS_L)
        .onClick(() => {
          if (!this.isComplete && this.target && this.sessionId) {
            WebClient.cancel(this.target, this.sessionId)
          }
          this.controller.close()
        })
      Blank().height(SizeConstant.SPACE_L)
    }
    .padding(SizeConstant.SPACE_L)
    .backgroundColor(Color.Transparent)
  }

  aboutToAppear(): void {
    this.sendPrepareUpload()
  }

  aboutToDisappear(): void {
    this.isComplete = true
    this.terminate?.terminate()
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
          this.controller.close()
          this.pages.pushDestination({ name: Routers.TRANSFER_PAGE, param: parma })
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