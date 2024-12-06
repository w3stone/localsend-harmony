import { RandomUtil } from '@pura/harmony-utils';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit';
import { Errors, SizeConstant, toast } from 'common';
import { Icon, NavigationTitle } from '../../components';
import { buffer, JSON } from '@kit.ArkTS';
import { DeviceProvider, FileProvider, mime, ObservedArray } from '../../utils';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { DeviceMapper } from '../../db/mapper';
import { Connection, Page, Wapper } from 'rdbplus';
import { CardColumn } from './CardColumn';
import { NearbyDeviceModel, ReceiveRecordModel } from '../../model';
import { ReceivedRecordMapper } from '../../db/mapper/ReceiveRecordMapper';

@Builder
export function DeveloperToolsPageBuilder() {
  DeveloperToolsPage()
}

@Component
export struct DeveloperToolsPage {
  @State progress: number = 0
  @State total: number = 5665497088
  @State isCollapsed: boolean = false
  @State receivedFileDir: string = `${getContext(this).filesDir}/received`
  @State fileNames: ObservedArray<string> = []
  @State selected: string | null = null
  @State saveButtonOptions: SaveButtonOptions = {
    icon: SaveIconStyle.FULL_FILLED,
    // text: SaveDescription.SAVE_IMAGE,
    buttonType: ButtonType.Normal
  }

  build() {
    NavDestination() {
      NavigationTitle({ title: '开发者工具' }) {
        Scroll() {
          Column() {
            CardColumn() {
              Progress({ value: this.progress, total: this.total, type: ProgressType.Linear })
                .style({ strokeWidth: 10, enableSmoothEffect: true })
                .color($r('app.color.primary'))
              Text() {
                Span(`progress: ${this.progress}`)
                Span(` - total: ${this.total} - `)
                Span(`${((this.progress / this.total) * 100).toFixed(2)}%`)
              }

              Blank().height(SizeConstant.SPACE_M)
              Row() {
                Button('重置').onClick(() => {
                  this.progress = 0
                })
                Blank().width(SizeConstant.SPACE_M)
                Button('长按更新')
                  .onTouch(() => {
                    const next: number = RandomUtil.getRandomInt(10000, 500000)
                    if ((this.progress + next) > this.total) {
                      this.progress = this.total
                    } else {
                      this.progress += next
                    }
                  })
              }
            }

            CardColumn() {
              List({ space: 10 }) {
                ForEach(this.fileNames, (fileName: string) => {
                  ListItem() {
                    Row() {
                      Text(fileName).fontSize(14)
                      Blank().width(10)
                      Icon({ src: $r('app.media.ic_delete') }).onClick(() => {
                        this.delFile(fileName)
                      })
                      SaveButton(this.saveButtonOptions)
                        .onClick(async (_, result: SaveButtonOnClickResult) => {
                          this.onSaveImageToAlbumClick(result, fileName)
                        })
                    }
                  }
                  .onClick(() => {
                    this.onFileItemClick(fileName)
                  })
                }, (fileName: string, index: number) => `${fileName}_${index}`)
              }
              .listDirection(Axis.Vertical)
              .width('100%')
              .height('auto')
              .constraintSize({ maxHeight: 200 })

              Blank().height(SizeConstant.SPACE_M)
              Row() {
                Button('获取已接收文件列表').onClick(() => {
                  this.getFiles()
                })
              }

              Blank().height(SizeConstant.SPACE_M)
              Row() {
                Button('获取发送缓存列表').onClick(() => {
                  this.getCacheFiles()
                })
                Blank().width(SizeConstant.SPACE_M)
                Button('清除缓存列表').onClick(() => {
                  this.clearCacheFiles()
                })
              }

            }

            CardColumn() {
              Button('删除表').onClick(() => {
                this.onDropDeviceTableClick()
              })
              Blank().height(SizeConstant.SPACE_M)
              Button('添加到收藏夹').onClick(() => {
                this.onAddCollectedClick()
              })
              Blank().height(SizeConstant.SPACE_M)
              Button('获取收藏夹列表').onClick(() => {
                this.onCollectedClick()
              })
              Blank().height(SizeConstant.SPACE_M)
              // Button('Can i use').onClick(() => {
              //   if (!canIUse('SystemCapability.FileManagement.AppFileService.FolderAuthorization')) {
              //     console.error('this api is not supported on this device');
              //     return;
              //   } else {
              //     console.info('this api is supported on this device');
              //   }
              // })
            }

            CardColumn({ title: '接收记录' }) {
              Button('插入一条接收记录').onClick(() => {
                this.onInsertReceiveRecordClick()
              })
              Blank().height(SizeConstant.SPACE_M)
              Button('读取接收记录').onClick(() => {
                this.onSelectReceiveRecordClick()
              })
              Blank().height(SizeConstant.SPACE_M)
              Button('清空接收记录').onClick(() => {
                this.onClearReceiveRecordClick()
              })
              Blank().height(SizeConstant.SPACE_M)
            }
          }
          .justifyContent(FlexAlign.Start)
          .padding(SizeConstant.SPACE_L)
          .constraintSize({ minHeight: '100%', minWidth: '100%' })
        }
        .width('100%')
        .height('100%')
      }
    }
    .hideTitleBar(true)
  }

  getFiles() {
    const dir: string = `${getContext(this).filesDir}/received`
    fs.listFile(dir)
      .then((files: string[]) => {
        this.fileNames = files
        console.log(`files: ${JSON.stringify(files)}`)
      })
      .catch((reason: object) => {
        console.log(`getFiles error: ${Errors.getErrorMessage(reason)}`)
      })
  }

  getCacheFiles() {
    console.info(`cacheDir: ${getContext(this).cacheDir}\nfilesDir: ${getContext(this).filesDir}`)
    const dir: string = `${getContext(this).cacheDir}/pending_to_send`
    fs.access(dir, fs.AccessModeType.EXIST)
      .then((exist) => {
        if (exist) {
          return fs.listFile(dir)
        } else {
          return Promise.reject('dir not exist')
        }
      })
      .then((files: string[]) => {
        console.log(`files: ${JSON.stringify(files)}`)
      })
      .catch((err: object) => {
        console.error(`files: ${Errors.getErrorMessage(err)}`)
      })
  }

  clearCacheFiles() {
    FileProvider.clearMediaCache(getContext(this))
      .then<void>(() => {
        this.getCacheFiles()
      })
      .catch((err: object) => {
        console.error(`clearCacheFiles error: ${Errors.getErrorMessage(err)}`)
      })
  }

  async onDropDeviceTableClick() {
    const mapper: DeviceMapper = new DeviceMapper()
    const conn: Connection = await mapper.getConnection()
    await conn.execDML('DROP TABLE t_device;')
    console.info('表已删除')
  }

  async onAddCollectedClick() {
    const mapper: DeviceMapper = new DeviceMapper()
    const devices: NearbyDeviceModel[] = DeviceProvider.getAllDevice()
    if (devices.length == 0) {
      console.warn('附近没有设备')
      return
    }
    await mapper.insertOrUpdate(devices[0])
  }

  async onCollectedClick() {
    const mapper: DeviceMapper = new DeviceMapper()
    await mapper.getList(new Wapper())
  }

  async onSaveImageToAlbumClick(result: SaveButtonOnClickResult, fileName: string) {
    if (result == SaveButtonOnClickResult.SUCCESS) {
      try {
        let context = getContext();
        let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
        // 需要确保fileUri对应的资源存在
        const fileUri: string = `${getContext(this).filesDir}/received/${fileName}`
        const fileType: string | null = mime.getType(fileUri)
        if (fileType?.startsWith('image')) {
          let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
            photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(context, fileUri);
          await phAccessHelper.applyChanges(assetChangeRequest);
          console.info('createAsset successfully, uri: ' + assetChangeRequest.getAsset().uri);
          toast.show('转存成功')
        } else if (fileType?.startsWith('video')) {
          let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
            photoAccessHelper.MediaAssetChangeRequest.createVideoAssetRequest(context, fileUri);
          await phAccessHelper.applyChanges(assetChangeRequest);
          toast.show('转存成功')
          console.info('createAsset successfully, uri: ' + assetChangeRequest.getAsset().uri);
        } else if (fileType?.startsWith('application')) {
          let uri: string = `${getContext(this).filesDir}/received/${fileName}`
          this.saveFileToDownload(uri)
          // 请确保 getContext(this) 返回结果为 UIAbilityContext

        }
      } catch (err) {
        console.error(`create asset failed with error: ${err.code}, ${err.message}`);
      }
    } else {
      console.error('SaveButtonOnClickResult create asset failed');
    }
  }

  async delFile(fileName: string) {
    try {
      const dir: string = `${getContext(this).filesDir}/received/${fileName}`
      const stat: fs.Stat = await fs.stat(dir)
      console.info(`删除文件 isFile: ${stat.isFile()} pathName: ${dir}`)
      await fs.rmdir(dir)
      console.info(`文件已删除: ${dir}`)
      this.getFiles()
    } catch (e) {
      console.warn(Errors.getErrorMessage(e))
    }
  }

  async onFileItemClick(fileName: string) {
    try {
      const filePath: string = `${getContext(this).filesDir}/received/${fileName}`
      const stat: fs.Stat = await fs.stat(filePath)
      const fileType: string | null = mime.getType(filePath)
      console.info(`文件大小: ${stat.size} => ${FileProvider.formatBytes(stat.size)} 文件类型： ${fileType} filePath: ${filePath}`)
      if (fileType) {
        this.calFileMd5(filePath)
      }
    } catch (e) {
      console.warn(Errors.getErrorMessage(e))
    }
  }

  async calFileMd5(fileUrl: string) {
    try {
      let md = cryptoFramework.createMd('MD5');
      let file = await fs.open(fileUrl, fs.OpenMode.READ_ONLY);
      let arrayBuffer = new ArrayBuffer(2048);
      let len: number = 0;
      let position: number = 0;
      do {
        len = fs.readSync(file.fd, arrayBuffer, { offset: position });
        if (len > 0) {
          let uint8Array = new Uint8Array(arrayBuffer.slice(0, len));
          let updateMessageBlob: cryptoFramework.DataBlob = { data: uint8Array };
          await md.update(updateMessageBlob);
          position += len;
        }
      } while (len > 0);
      fs.close(file);
      let mdOutput = await md.digest();
      console.info('...calFileMd5: ' + buffer.from(mdOutput.data).toString('hex'));
    } catch (e) {
      console.info('...calFileMd5 error: ' + Errors.getErrorMessage(e));
    }
  }

  async getSaveFile(newFileNames: string[]): Promise<Array<string>> {
    // 请确保 getContext(this) 返回结果为 UIAbilityContext
    let context = getContext(this) as common.Context;
    const documentViewPicker = new picker.DocumentViewPicker(context);
    const documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
    documentSaveOptions.newFileNames = newFileNames
    return await documentViewPicker.save(documentSaveOptions)
    // if (result.length > 0) {
    //   logger.info('DevTool', `save result: ${JSON.stringify(result)}`)
    //   const uri = result[0] + '/' + newFileNames[0]
    //   logger.info('DevTool', `fileName: ${uri}`)
    //   AppStorage.setOrCreate('FILE_SAVE_DIR', uri)
    //   return uri
    // } else {
    //   toast.show('获取保存目录失败')
    //   return ''
    // }
  }

  async saveFileToDownload(fileName: string) {
    const documentSaveResult: string[] = await this.getSaveFile([fileName])
    if (documentSaveResult && documentSaveResult.length > 0) {
      let fileUriObject = new fileUri.FileUri(documentSaveResult[0]);
      let directoryUri = fileUriObject.getFullDirectoryUri();
      const dirPath = getContext(this).filesDir;
      let destPath = dirPath + directoryUri;
      fs.copyDir(getContext(this).filesDir + '/received', destPath, fs.OpenMode.READ_WRITE).then(() => {
        console.info("copy directory succeed");
      }).catch((err: BusinessError) => {
        console.error(`copy directory failed with error message: ${err.message} , error code: ${err.code}`);
      });
    }
  }

  async onInsertReceiveRecordClick() {
    try {
      const mapper = new ReceivedRecordMapper()
      const record = new ReceiveRecordModel()
      record.fileName = `${RandomUtil.getRandomStr(10, 'abcdadsasdofiefhefiewfhweiokjksdkjfhsbzxcz')}.txt`
      record.size = RandomUtil.getRandomInt(6200, 12120)
      record.fileType = 'application/html'
      record.sender = '炽热的西兰花'
      record.sendAt = 1733394035000
      record.filePath = 'file://docs/storage/Users/username'
      await mapper.insert(record)
      console.info(`接收记录保存成功: ${JSON.stringify(record)}`)
    } catch (e) {
      console.error(`插入接收记录失败: ${JSON.stringify(Errors.getErrorMessage(e))}`)
    }
  }

  async onSelectReceiveRecordClick() {
    try {
      const mapper = new ReceivedRecordMapper()
      const page: Page<ReceiveRecordModel> = await mapper.getPage(1, 30, new Wapper())
      // const records: ReceiveRecordModel[] = await mapper.getList(new Wapper())
      console.info(`page: ${JSON.stringify(page)}`)
    } catch (e) {
      console.error(`获取接收记录失败: ${JSON.stringify(Errors.getErrorMessage(e))}`)
    }
  }

  async onClearReceiveRecordClick() {
    try {
      const mapper = new ReceivedRecordMapper()
      mapper.delete(new Wapper())
      console.info(`the received record has been deleted..`)
    } catch (e) {
      console.error(`获取接收记录失败: ${JSON.stringify(Errors.getErrorMessage(e))}`)
    }
  }
}