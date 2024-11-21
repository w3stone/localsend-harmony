import { HttpError, IncomingMessage, polka, Polka, Request, ServerResponse } from 'serve';
import {
  DeviceModel,
  MulticastModel,
  PrepareTransferModel,
  PrepareUploadModel,
  ReceiveResultAction,
  ReceiveResultActionType
} from '../model';
import { socket } from '@kit.NetworkKit';
import { Errors, logger, Strings } from 'common';
import { buffer, JSON } from '@kit.ArkTS';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { Keys } from '../constant';
import { WebClient } from './WebClient';
import { DeviceProvider } from '../utils';
import { EventBus, EventType, PrepareUploadEvent } from '../eventbus';
import { FileProvider } from '../utils/FileProvider';
import { FileReceptionService } from './FileReceptionService';

const TAG: string = "WebService"
const app: Polka<Request> = polka({
  subscriber: {
    onConnect(req: IncomingMessage, res: ServerResponse) {
    },
    onHeader(req: IncomingMessage, res: ServerResponse) {
      logger.info(TAG, "--- header-event ---")
    },
    onData(req: IncomingMessage, res: ServerResponse, stream: buffer.Buffer) {
      new Promise<void>((resolve, reject) => {
        const buf = buffer.alloc(1000)
        const len = (stream.length > 1000) ? 1000 : stream.length
        stream.copy(buf, 0, 0, len)
        logger.info(TAG, 'onData => ' + Strings.buf2String(buf.buffer))
        return
      })
      logger.info('WebService', `上传进度：`)
    }
  }
})
const udp: socket.MulticastSocket = socket.constructMulticastSocketInstance();

export class WebService {
  isRunning: boolean = false
  alias: string = ''
  port: number = AppStorage.get(Keys.PORT) || 53317
  multicast: string = '224.0.0.167'

  constructor(alias: string) {
    this.alias = alias
  }

  start(port: number | undefined = undefined) {
    if (port) {
      this.port = this.port
    }
    udp.addMembership({ address: this.multicast, port: this.port }, (err: BusinessError) => {
      if (err) {
        logger.info(TAG, `>>>--- UDP 组播添加失败 -> ${JSON.stringify(err)}`)
      } else {
        logger.info(TAG, `>>>--- UDP 组播已添加 -> Running: ${this.multicast}:${this.port}`);
      }
    })
    udp.on("listening", () => {
      logger.info(TAG, `---<<< UDP  -> listening`);
    })
    udp.on('close', () => {
      logger.info(TAG, `---<<< UDP  -> close`);
    })
    udp.on('message', (info: socket.SocketMessageInfo) => {
      let message = Strings.buf2String(info.message)
      let device: DeviceModel = JSON.parse(message) as DeviceModel
      if (device && device.fingerprint != DeviceProvider.getDeviceFingerprint() && device.announce == true) {
        device.hostname = info.remoteInfo.address
        DeviceProvider.addOrReplaceDevice(info.remoteInfo.address, device)
        logger.info(TAG, '<<<---UDP received message: ' + JSON.stringify(device));
        WebClient.register(device)
      }
    })
    app
      .get("/", this.index)
      .post("/api/localsend/v2/register", this.register)
      .post("/api/localsend/v2/prepare-upload", this.prepareUpload)
      .post("/api/localsend/v2/upload", this.upload)
      .post("/api/localsend/v2/cancel", this.cancel)
      .post("/api/localsend/v2/download", this.cancel)
      .listen(this.port, "0.0.0.0")
      .then((isRunning: boolean) => {
        AppStorage.setOrCreate(Keys.SERVICE_IS_ONLINE, isRunning)
        this.isRunning = isRunning
        this.scanOtherDevice()
      })
  }

  async stop(): Promise<void> {
    this.isRunning = false
    try {
      app.server?.stop()
      udp.off("message")
      await udp.dropMembership({ address: this.multicast, port: this.port })
      await udp.close()
    } catch (e) {
      logger.warn(TAG, `WebService stop error: ${Errors.getErrorMessage(e)}`)
    } finally {
      AppStorage.set(Keys.SERVICE_IS_ONLINE, false)
    }
  }

  scanOtherDevice() {
    const address: socket.NetAddress = { address: this.multicast, port: this.port }
    let options: socket.UDPSendOptions = {
      data: JSON.stringify(new MulticastModel(true)),
      address: address
    }
    udp.send(options, (err: BusinessError) => {
      if (err) {
        logger.error(TAG, "--->>> UDP 组播失败 %s", JSON.stringify(err))
      } else {
        logger.error(TAG, "--->>> UDP 组播已发送 %s", JSON.stringify(options))
      }
    })
  }

  private index(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<--- index: " + req.remote.address)
    res.end(JSON.stringify({ "msg": "ok", "code": 1000 }))
  }

  private register(req: IncomingMessage, res: ServerResponse) {
    const device: DeviceModel = req.body as DeviceModel
    device.hostname = req.remote.address
    logger.info(TAG, "<<<--- register: " + JSON.stringify(device))
    DeviceProvider.addOrReplaceDevice(req.remote.address, device)
    res.writeJson(new MulticastModel(false))
  }

  private prepareUpload(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, `<<<--- prepare-upload ${req.originalUrl} \nbody:${JSON.stringify(req.body)}`)
    if (FileProvider.isTransferringNow()) {
      res.setStatusCode(409).writeJson({ message: "Blocked by another session" })
      return
    }
    const body = req.body as PrepareUploadModel
    if (!body) {
      res.setStatusCode(400).writeJson({ message: 'Invalid body' })
      return
    }
    if (Object.keys(body.files).length == 0) {
      res.setStatusCode(400).writeJson({ message: 'Request must contain at least one file' })
      return
    }
    EventBus.getInstance().once(EventType.RECEIVE_SEND_REQUEST_ACTION, (eventData: emitter.EventData) => {
      const data = eventData.data as ReceiveResultAction
      if (data) {
        if (data.action == ReceiveResultActionType.ACCEPT) {
          new Promise<PrepareTransferModel>((resolve, reject) => {
            try {
              const prepare: PrepareUploadModel = req.body as PrepareUploadModel
              const result: PrepareTransferModel = FileReceptionService.getPrepareReceptionData(prepare)
              FileProvider.addFilesToReceiveQueue(prepare, result, req.remote.address)
              resolve(result)
            } catch (e) {
              reject(e)
            }
          }).then((result) => res.writeJson(result))
            .catch(() => {
              res.setStatusCode(data.code || 500).writeJson({ message: "Unknown error by receiver" })
              FileProvider.clearFilesReceiveQueue()
            })
        } else if (data.action == ReceiveResultActionType.REJECT) {
          res.setStatusCode(403)
            .writeJson({ message: "File request declined by recipient" })
        } else if (data.action == ReceiveResultActionType.COMPLETE) {
          res.setStatusCode(204)
            .writeJson({})
        } else {
          res.setStatusCode(data.code || 500)
            .writeJson({ message: "Unknown error by receiver" })
        }
      } else {
        logger.error('WebService', `prepareUpload: event data is null ${JSON.stringify(eventData.data)}`)
        res.setStatusCode(500)
          .writeJson({ message: "Unknown error by receiver" })
      }
    })
    EventBus.getInstance().post(EventType.RECEIVE_SEND_REQUEST, PrepareUploadEvent(body))
  }

  private upload(req: IncomingMessage, res: ServerResponse) {

    logger.info(TAG, "<<<--- upload " + req.originalUrl)
    const isReceivingFiles = FileProvider.isTransferringNow()
    //当前位处于接收文件状态，直接调用了upload接口
    if (!isReceivingFiles) {
      res.setStatusCode(403).writeJson({ message: "Invalid token or IP address" })
      return
    }
    const sessionId = req.queryParameters.get('sessionId')
    //sessionId未传
    if (!sessionId) {
      res.setStatusCode(400).writeJson({ message: "Missing parameters" })
      return
    }
    //当前正在接收文件但不是发送请求的这台设备
    if (isReceivingFiles && FileProvider.getTransferringNowSessionId() !== sessionId) {
      res.setStatusCode(409).writeJson({ message: "Blocked by another session" })
      return
    }
    const token = req.queryParameters.get('token')
    if (!token) {
      res.setStatusCode(403).writeJson({ message: "Invalid token or IP address" })
      return
    }
    new Promise<void>(() => {
      const info = FileProvider.getReceiveFileInfo(token)
      //未找到队列指定token的文件接收信息，或当前请求IP与该token文件信息中IP不一致
      if (!info || info.remoteIp != req.remote.address) {
        throw HttpError.error(403, 'Invalid token or IP address')
      }
      logger.info(TAG, `--- upload ${FileProvider.formatBytes(req.getContentLength())}`)
      //保存文件
      return 200
    }).then(_ => {
      res.end(undefined)
    }).catch((error: Error) => {
      if (error instanceof HttpError) {
        res.setStatusCode(error.status).writeJson({ message: error.message })
      } else {
        logger.error(TAG, `文件保存失败: ${error.message} \n${error.stack}`)
        res.setStatusCode(500).writeJson({ message: 'Unknown error by receiver' })
      }
    })
    res.end(JSON.stringify({ "msg": "ok", "code": 1000 }))
  }

  private cancel(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<---cancel: " + req.remote.address)
    res.end(JSON.stringify({ "msg": "ok", "code": 1000 }))
  }

  private download(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<---download: " + req.remote.address)
    res.end(JSON.stringify({ "msg": "ok", "code": 1000 }))
  }
}

