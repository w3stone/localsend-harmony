import { NavigationTitle } from '../../../../components';
import { buffer, util } from '@kit.ArkTS';
import { FileProvider } from '../../../../utils';
import { fileIo as fs } from '@kit.CoreFileKit';

@Component
export struct Setting {
  @State uuid: string = ''
  @Consume('pages') pages: NavPathStack;

  build() {
    // 卡片折叠态，展开态的共同父组件
    Stack() {
      NavigationTitle({ title: $r('app.string.select') }) {
        Column() {
          Text(this.uuid)
          Button('UUID')
            .onClick(() => {
              this.uuid = util.generateRandomUUID(true)
            })
          Button("跳转到接收文件界面")
            .onClick(() => {
              this.pages.pushDestination({ name: 'ReceivingPage' })
            })
          Button("读文件")
            .onClick(() => {
              this.readeFile().then()
            })
        }
        .width('100%')
        .height('100%')
      }
    }
  }

  async readeFile(): Promise<string> {
    //文件分片大小 8k
    const MAX_READ_LENGTH = 8192
    console.info('开始读取文件')
    try {
      const filePath =
        'file://docs/storage/Users/currentUser/Download/com.huawei.distributedpasteboard/cache/dragdrop/IMG_1729796931417.png'
      const file = await FileProvider.getFile(filePath)
      let input = new ArrayBuffer(MAX_READ_LENGTH)
      let readSize: number = 0
      let length: number = await fs.read(file.fd, input, { offset: readSize, length: MAX_READ_LENGTH })
      readSize += length
      console.info(`input: ${buffer.from(input).toString()}`)
      while (length > 0) {
        input = new ArrayBuffer(MAX_READ_LENGTH)
        length = await fs.read(file.fd, input, { offset: readSize, length: MAX_READ_LENGTH })
        readSize += length
        console.info(`input: ${buffer.from(input).toString()}`)
      }
      fs.close(file)
    } catch (e) {
      console.error(`文件读取失败: ${e.message}\n${e.stack}`)
    }
    return ''
  }
}