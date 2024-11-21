import { SizeConstant } from 'common'
import { Icon } from '../../../../components'
import { Keys } from '../../../../constant'
import { EventBus, EventType, NumberEvent } from '../../../../eventbus'
import { ServiceActionType } from '../../../../model'

@Component
export struct ServiceAction {
  @StorageLink(Keys.SERVICE_IS_ONLINE) isOnline: boolean = true

  build() {
    Row() {
      Icon({
        src: this.isOnline ? $r('app.media.ic_reset') : $r('app.media.ic_start'),
        spacing: 2,
        iconColor: $r('app.color.on_container')
      }).onClick(() => {
        if (this.isOnline) {
          EventBus.getInstance().post(EventType.SERVICE_ACTION, NumberEvent(ServiceActionType.Restart))
        } else {
          EventBus.getInstance().post(EventType.SERVICE_ACTION, NumberEvent(ServiceActionType.Start))
        }
      })
      Blank().width(SizeConstant.SPACE_M)
      Icon({ src: $r('app.media.ic_stop'), iconColor: this.isOnline ? $r('app.color.on_container') : $r('app.color.icon') })
        .enabled(this.isOnline)
        .onClick(() => {
          EventBus.getInstance().post(EventType.SERVICE_ACTION, NumberEvent(ServiceActionType.Stop))
        })
    }
  }
}