import polka, { IncomingMessage, Polka, Request, ServerResponse } from '@ohos/polka';
import { MulticastModel } from '../model';
import { socket } from '@kit.NetworkKit';
import { buf2String, logger } from 'common';
import { JSON } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { NetAddress } from '../constant';
import { DeviceModel } from '../model/DeviceModel';
import { ResponseService } from './ResponseService';

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
    if (this.isRunning) {
      logger.info(TAG, "Start service: Service is already running")
      return
    }
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

    let options: socket.UDPSendOptions = {
      data: JSON.stringify(new MulticastModel(this.alias, NetAddress.port)),
      address: NetAddress
    }
    // udp.send(options, (err: BusinessError) => {
    //   if (err) {
    //     logger.error(TAG, "--->>> UDP 广播失败 %s", JSON.stringify(err))
    //   } else {
    //     logger.error(TAG, "--->>> UDP 组播已发送 %s", JSON.stringify(options))
    //   }
    // })
    udp.on('message', (info: socket.SocketMessageInfo) => {
      let message = buf2String(info.message)
      logger.info(TAG, '<<<--- received message: ' + message);
      let model: DeviceModel = JSON.parse(message) as DeviceModel
      if (model && model.announce == true) {
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
      .listen(NetAddress.port, "0.0.0.0", (message: string) => {
        this.isRunning = true
        logger.info(TAG, "Web service: %s", message)
      })
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

  private index(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<--- index: " + req.getRemoteIpAddress())
    res.end(JSON.stringify({ "msg": "ok", "code": 1000 }))
  }

  private register(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<--- register: " + JSON.stringify(req.parameters))
    res.end(JSON.stringify(new MulticastModel(this.alias, NetAddress.port, false)))
  }

  private prepareUpload(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<--- prepareUpload" + req.getRemoteIpAddress())
    res.end(JSON.stringify({ "msg": "ok", "code": 1000 }))
  }

  private upload(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<--- prepareUpload" + req.getRemoteIpAddress())
    res.end(JSON.stringify({ "msg": "ok", "code": 1000 }))
  }

  private cancel(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<---download: " + req.getRemoteIpAddress())
    res.end(JSON.stringify({ "msg": "ok", "code": 1000 }))
  }

  private download(req: IncomingMessage, res: ServerResponse) {
    logger.info(TAG, "<<<---download: " + req.getRemoteIpAddress())
    res.end(JSON.stringify({ "msg": "ok", "code": 1000 }))
  }
}

