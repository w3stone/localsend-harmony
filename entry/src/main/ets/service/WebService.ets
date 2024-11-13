import { IncomingMessage, polka, Polka, Request, ServerResponse } from 'serve';
import {
  AcceptReceiveModel,
  DeviceModel,
  MulticastModel,
  PrepareUploadModel,
  ReceiveResultAction,
  ReplyErrorModel,
  ReceiveResultActionType
} from '../model';
import { socket } from '@kit.NetworkKit';
import { buf2String, logger } from 'common';
import { JSON } from '@kit.ArkTS';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { NetAddress } from '../constant';
import { ResponseService } from './ResponseService';
import { DeviceProvider, SessionProvider } from '../utils';
import { EventBus, EventType, PrepareUploadEvent } from '../eventbus';
import { FileProvider } from '../utils/FileProvider';

const TAG: string = "WebService"
const app: Polka<Request> = polka()
const udp: socket.MulticastSocket = socket.constructMulticastSocketInstance();

export class WebService {
  isRunning: boolean = false
  alias: string = ''

  constructor(alias: string) {
    this.alias = alias
  }

  start() {
    udp.addMembership(NetAddress, (err: BusinessError) => {
      if (err) {
        logger.info(TAG, `>>>--- UDP 组播添加失败 -> ${JSON.stringify(err)}`)
      } else {
        logger.info(TAG, `>>>--- UDP 组播已添加 -> Running: ${NetAddress.address}:${NetAddress.port}`);
      }
    })
    udp.on("listening", () => {
      logger.info(TAG, `---<<< UDP  -> listening`);
    })
    udp.on('close', () => {
      logger.info(TAG, `---<<< UDP  -> listening`);
    })
    udp.on('message', (info: socket.SocketMessageInfo) => {
      let message = buf2String(info.message)
      logger.info(TAG, '<<<---UDP received message: ' + message);
      let model: DeviceModel = JSON.parse(message) as DeviceModel
      if (model && model.fingerprint != DeviceProvider.getDeviceFingerprint() && model.announce == true) {
        ResponseService.register(info.remoteInfo.address, this.alias, NetAddress.port!!)
      }
    })
    app
      .get("/", this.index)
      .post("/api/localsend/v2/register", this.register)
      .post("/api/localsend/v2/prepare-upload", this.prepareUpload)
      .post("/api/localsend/v2/upload", this.upload)
      .post("/api/localsend/v2/cancel", this.cancel)
      .post("/api/localsend/v2/download", this.cancel)
      .listen(NetAddress.port, "0.0.0.0")
    this.scanOtherDevice()
  }

  stop() {
    this.isRunning = false
    app.server?.stop()
    udp.dropMembership(NetAddress, (err: BusinessError) => {
      if (err) {
        logger.info(TAG, `退出组播失败: ${JSON.stringify(err)}`)
      } else {
        logger.info(TAG, `已退出组播: ${NetAddress.address}:${NetAddress.port}`)
      }
    })
    udp.off("message")
    udp.close(() => {
      logger.info(TAG, "Stoped services")
    })
  }

  scanOtherDevice() {
    let options: socket.UDPSendOptions = {
      data: JSON.stringify(new MulticastModel(this.alias, NetAddress.port)),
      address: NetAddress
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
    logger.info(TAG, "<<<--- register: " + JSON.stringify(device))
    DeviceProvider.addOrReplaceDevice(req.remote.address, device)
    res.writeJson(new MulticastModel(this.alias, NetAddress.port, false))
  }

  private prepareUpload(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, `<<<--- prepare-upload\n${JSON.stringify(req.body)}`)
    if (FileProvider.isReceivingFiles()) {
      res.setStatusCode(409)
        .writeJson(new ReplyErrorModel("Blocked by another session"))
      return
    }
    EventBus.getInstance().once(EventType.RECEIVE_SEND_REQUEST_ACTION, (eventData: emitter.EventData) => {
      const data = eventData.data as ReceiveResultAction
      if (data) {
        if (data.action == ReceiveResultActionType.ACCEPT) {
          const files: Map<string, string> = new Map()
          files['415c054e-b7ac-4bfe-8518-533f23f90f21'] = '8d2750ef-df0e-4f56-b352-cd0e8aaed35a'
          const receive = new AcceptReceiveModel(SessionProvider.generateSessionId(), files)
          FileProvider.addFileToReceiveQueue(receive)
          res.writeJson(receive)
        }else if (data.action == ReceiveResultActionType.REJECT) {
          res.setStatusCode(403)
            .writeJson(new ReplyErrorModel("File request declined by recipient"))
        }else {
          res.setStatusCode(data.code||500)
            .writeJson(new ReplyErrorModel("Unknown error by receiver"))
        }
      }else {
        res.setStatusCode(500)
          .writeJson(new ReplyErrorModel("Unknown error by receiver"))
      }
      // if (eventData.data?.value === true) {
      //   const files: Map<string, string> = new Map()
      //   files['415c054e-b7ac-4bfe-8518-533f23f90f21'] = '8d2750ef-df0e-4f56-b352-cd0e8aaed35a'
      //   const receive = new AcceptReceiveModel(SessionProvider.generateSessionId(), files)
      //   FileProvider.addFileToReceiveQueue(receive)
      //   res.writeJson(receive)
      // } else {
      //   res.setStatusCode(403)
      //     .writeJson(new ReplyErrorModel("File request declined by recipient"))
      // }
    })
    EventBus.getInstance().post(EventType.RECEIVE_SEND_REQUEST, PrepareUploadEvent(req.body as PrepareUploadModel))
  }

  private upload(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<--- upload" + req.remote.address)
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

