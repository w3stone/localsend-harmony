import { Icon } from '.';

@Component
export struct DeviceIcon {
  @Prop iconColor: ResourceColor = $r('app.color.icon')
  @Prop deviceType: string | 'mobile' | 'desktop' | 'web' | 'headless' | 'server' = 'web'
  @Prop dimension: Length = 60

  build() {
    Icon({ src: this.getIcon(this.deviceType), dimension: this.dimension, iconColor: this.iconColor })
  }

  //mobile | desktop | web | headless | server
  getIcon(deviceType: string): Resource {
    switch (deviceType) {
      case 'mobile':
        return $r('app.media.ic_mobile')
      case 'desktop':
        return $r('app.media.ic_computer')
      case 'server':
        return $r('app.media.ic_storage')
      case 'headless':
        return $r('app.media.ic_cli')
      case 'web':
        return $r('app.media.ic_web')
      default:
        return $r('app.media.ic_storage')
    }
  }
}