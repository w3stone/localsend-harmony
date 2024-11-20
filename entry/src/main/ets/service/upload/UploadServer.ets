import { socket } from '@kit.NetworkKit';
import { FileInfoModel, FileTransferStatus, StringPair } from '../../model';
import { fileIo as fs } from '@kit.CoreFileKit';
import { Errors, logger } from 'common';
import { buffer } from '@kit.ArkTS';
import { Dates, FileProvider } from '../../utils';
import { HttpProtocol } from './HttpProtocol';
import { TransferException } from './TransferException';
import { Terminator } from '../../http';
import { request, } from '@kit.BasicServicesKit';
import { Context } from '@kit.AbilityKit';

const TAG: string = 'UploaderServer'

//文件分片大小 8k
const MAX_READ_LENGTH = 8192
const CRLF = '\r\n'

export class UploaderServer implements Terminator {
  tcp: socket.TCPSocket = socket.constructTCPSocketInstance();
  hostname: string
  port: number
  isConnected: boolean = false
  terminated: boolean = false

  constructor(hostname: string, port: number,) {
    this.hostname = hostname
    this.port = port
  }

  config: request.agent.Config = {
    action: request.agent.Action.UPLOAD,
    headers: {},
    url: '',
    title: 'createTest',
    description: 'Sample code for create task',
    mode: request.agent.Mode.BACKGROUND,
    overwrite: false,
    method: "POST",
    data: [],
    saveas: "./",
    network: request.agent.Network.WIFI,
    metered: false,
    roaming: true,
    retry: true,
    redirect: true,
    index: 0,
    begins: 0,
    ends: -1,
    gauge: true,
    precise: false,
    token: "it is a secret"
  }
  task: request.agent.Task | null = null

  async createBackgroundTask(context: Context, url: string, token: string, fileUri: string) {
    const headers: StringPair = {}
    this.config.url = url;
    this.config.headers = headers
    this.config.data = [{
      name: 'LOG_20241106150606.zip',
      value: {
        path: fileUri
      }
    }];
    this.config.mode = request.agent.Mode.FOREGROUND;
    this.config.token = token
    try {
      logger.info(TAG, `create task: ` + JSON.stringify(this.config))
      this.task = await request.agent.create(context, this.config);
      this.task.on('progress', (progress: request.agent.Progress) => {
        logger.info(TAG, `progress,  progress = ${progress.processed} ${progress.state}`);
      })
      await this.task.start();
      logger.info(TAG, `createBackgroundTask success`);
    } catch (err) {
      logger.error(TAG, `task  err, err  = ${Errors.getErrorMessage(err)}`);
      throw new TransferException('task error')
    }
  }

  getAttachments(info: FileInfoModel): Array<request.agent.FormItem> {
    const items: request.agent.FormItem[] = []
    items.push({
      name: info.fileName,
      value: {
        // filename: info.fileName,
        // mimeType: info.fileType,
        path: info.filePath!!
      }
    })
    return items
  }

  /**
   * 上传文件二进制流
   * @param url 请求路径(相对路径)
   * @param info 需要上传的文件
   * @param callback 用于返回上传进度的回调函数
   * @returns
   */
  async upload(url: string, info: FileInfoModel,
    callback: (status: FileTransferStatus, progress: number, total: number, token: string,
      error?: object) => void): Promise<void> {
    let file: fs.File | null = null
    try {
      if (!info.filePath) {
        return Promise.reject()
      }
      file = await FileProvider.getFile(info.filePath)
      let input = new ArrayBuffer(MAX_READ_LENGTH)
      //已读文件长度
      let readSize: number = 0
      //本次读取到buffer的长度
      let start = Dates.now()
      let length: number = await fs.read(file.fd, input, { offset: readSize, length: MAX_READ_LENGTH })
      logger.info(TAG, `读取耗时: ${Dates.consumed(start)}ms`)
      readSize += length
      start = Dates.now()
      await this.sendChunked(url, info.size, input, info.fileType, false)
      logger.info(TAG, `发送耗时: ${Dates.consumed(start)}ms`)
      callback(FileTransferStatus.TRANSFERRING, readSize, info.size, info.id)
      //分片向服务器发送二进制流
      while (length > 0) {
        //上传被终止
        if (this.terminated) {
          break
        }
        input = new ArrayBuffer(MAX_READ_LENGTH)
        start = Dates.now()
        length = await fs.read(file.fd, input, { offset: readSize, length: MAX_READ_LENGTH })
        logger.info(TAG, `读取耗时: ${Dates.consumed(start)}`)
        readSize += length
        start = Dates.now()
        await this.sendChunked(url, info.size, (length < MAX_READ_LENGTH) ? input.slice(0, length) : input, info.fileType, true)
        logger.info(TAG, `发送耗时: ${Dates.consumed(start)}`)
        callback(FileTransferStatus.TRANSFERRING, readSize, info.size, info.id)
      }
      callback(FileTransferStatus.COMPLETED, readSize, info.size, info.id)
      logger.info(TAG, `文件上传成功 -> fileId: ${info.id}`)
    } catch (e) {
      logger.error(TAG, `上传文件失败: ${Errors.getErrorMessage(e)}`)
      callback(FileTransferStatus.ERROR, 0, info.size, info.id, e)
      return Promise.reject()
    } finally {
      if (file) {
        fs.close(file)
      }
    }
  }

  /**
   * 关闭TCP Socket链接，所有文件上传完成后关闭
   */
  disconnection() {
    this.tcp.close().then(() => {
      this.isConnected = false
    })
  }


  terminate() {
    this.terminated = true
    this.tcp.close().then(() => {
      this.isConnected = false
    })
  }

  private async connect(): Promise<void> {
    if (this.isConnected) {
      return
    }
    try {
      const address: socket.NetAddress = {
        address: this.hostname,
        port: this.port
      }
      const connectOption: socket.TCPConnectOptions = {
        address: address,
        timeout: 10000
      }
      await this.tcp.connect(connectOption)
      await this.tcp.setExtraOptions({
        keepAlive: true,
        TCPNoDelay: true
      })
      this.tcp.on('message', this.onMessage)
      this.isConnected = true
    } catch (e) {
      this.isConnected = false
      logger.warn(TAG, `服务器连接失败: ${Errors.getErrorMessage(e)}`)
      throw new TransferException(e.message)
    }
  }

  private onMessage(info: socket.SocketMessageInfo) {

    logger.debug(TAG, `<<<---UploadResponse: \n${buffer.from(info.message).toString()}`)
  }

  /**
   * 发送分片数据
   * @param url 请求路径(相对路径)
   * @param fileSize 文件大小,
   * @param stream 分片数据
   * @param fileType 文件类型
   * @param isFirst 是否为初次发送
   * @returns
   */
  private async sendChunked(url: string, fileSize: number, stream: ArrayBuffer, fileType: string,
    isFirst: boolean): Promise<void> {
    await this.connect()
    if (!isFirst) {
      const protocol = new HttpProtocol(this.hostname, this.port)
      protocol.method = 'POST'
      protocol.hostname = this.hostname
      protocol.url = url
      protocol.setContentType(fileType)
      protocol.setContentLength(fileSize)
      protocol.addHeader("Transfer-Encoding", 'chunked')
      protocol.content = this.getChunkedStream(stream)
      await this.tcp.send({ data: protocol.toMessage() })
    } else {
      await this.tcp.send({ data: this.getChunkedStream(stream) })
    }
  }

  /**
   * 添加chunked协议数据并返回
   * @param input 需要传输的流
   * @returns
   */
  private getChunkedStream(input: ArrayBuffer): ArrayBuffer {
    const start = `${input.byteLength.toString(16)}${CRLF}`
    const buff = buffer.allocUninitializedFromPool(start.length + input.byteLength + CRLF.length)
    buff.write(start)
    buffer.from(input).copy(buff, start.length, 0, input.byteLength)
    buff.write(CRLF, start.length + input.byteLength, CRLF.length)
    return buff.buffer
  }
}