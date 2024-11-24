import { socket } from '@kit.NetworkKit';
import { FileInfoModel, FileTransferStatus, TransferProgressChangedAction } from '../../model';
import { fileIo as fs } from '@kit.CoreFileKit';
import { Errors, logger } from 'common';
import { buffer } from '@kit.ArkTS';
import { Dates, FileProvider } from '../../utils';
import { HttpProtocol } from './HttpProtocol';
import { TransferException } from './TransferException';
import { Terminator } from '../../http';

const TAG: string = 'UploaderServer'

const CRLF = '\r\n'

export class UploaderServer implements Terminator {
  tcp: socket.TCPSocket = socket.constructTCPSocketInstance();
  hostname: string
  port: number
  isConnected: boolean = false
  terminated: boolean = false
  listener: (event: TransferProgressChangedAction) => void

  constructor(hostname: string, port: number, listener: (event: TransferProgressChangedAction) => void) {
    this.hostname = hostname
    this.port = port
    this.listener = listener
  }

  /**
   * 上传文件二进制流
   * @param url 请求路径(相对路径)
   * @param info 需要上传的文件
   * @param callback 用于返回上传进度的回调函数
   * @returns
   */
  async upload(filePortSize: number, url: string, info: FileInfoModel): Promise<void> {
    let file: fs.File | null = null
    try {
      if (!info.filePath) {
        return Promise.reject()
      }
      let start = Dates.now()
      file = await FileProvider.getFile(info.filePath)
      let input = new ArrayBuffer(filePortSize)
      //已读文件长度
      let readSize: number = 0
      //本次读取到buffer的长度
      let length: number = await fs.read(file.fd, input, { offset: readSize, length: filePortSize })
      readSize += length
      await this.sendChunked(url, info.size, input, info.fileType, false)
      this.listener({
        fileId: info.id,
        status: FileTransferStatus.TRANSFERRING,
        progress: readSize,
        total: info.size,
        speed: this.getSpeed(readSize, Dates.consumed(start))
      })
      let lastCallTime: number = 0
      //分片向服务器发送二进制流
      while (length > 0) {
        //上传被终止
        if (this.terminated) {
          break
        }
        // let started: number = Dates.now()
        input = new ArrayBuffer(filePortSize)
        length = await fs.read(file.fd, input, { offset: readSize, length: filePortSize })
        // let consumed: number = Dates.consumed(started)
        // if (consumed > 3) {
        //   logger.info(TAG, `读取耗时: ${Dates.consumed(started)}ms`)
        // }
        readSize += length
        // started = Dates.now()
        await this.sendChunked(url, info.size, (length < filePortSize) ? input.slice(0, length) : input, info.fileType, true)
        // consumed = Dates.consumed(started)
        // if (consumed > 3) {
        //   logger.info(TAG, `发送耗时: ${Dates.consumed(started)}ms`)
        // }
        //大于50ms时发送一次进度更新消息
        const elapsed = Dates.consumed(lastCallTime)
        if (elapsed > 200) {
          this.listener({
            fileId: info.id,
            status: FileTransferStatus.TRANSFERRING,
            progress: readSize,
            total: info.size,
            speed: this.getSpeed(readSize, Dates.consumed(start))
          })
          lastCallTime = Dates.now()
        }
      }
      if (this.terminated) {
        logger.info(TAG, `文件上传中断 -> fileId: ${info.id}`)
        this.listener({
          fileId: info.id,
          status: FileTransferStatus.CANCELED,
          progress: readSize,
          total: info.size,
          speed: 0
        })
      } else {
        // logger.info(TAG, `文件上传成功 -> fileId: ${info.id}`)
        this.listener({
          fileId: info.id,
          status: FileTransferStatus.COMPLETED,
          progress: readSize,
          total: info.size,
          speed: this.getSpeed(readSize, Dates.consumed(start))
        })
      }
    } catch (e) {
      logger.error(TAG, `上传文件失败: ${Errors.getErrorMessage(e)}`)
      this.listener({
        fileId: info.id,
        status: FileTransferStatus.ERROR,
        progress: 0,
        total: info.size,
        speed: 0,
        error: e
      })
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

  /**
   * 终止上传
   */
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
        TCPNoDelay: true,
        receiveBufferSize: 2 * 1024 * 1024,
        sendBufferSize: 2 * 1024 * 1024
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
    // logger.debug(TAG, `<<<---UploadResponse: \n${buffer.from(info.message).toString()}`)
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
  private async sendChunked(url: string, fileSize: number, stream: ArrayBuffer, fileType: string, isFirst: boolean): Promise<void> {
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

  /**
   * 返回传输速度 单位：字节/s
   * @param size 传输大小byte
   * @param time 传输时间ms
   * @returns
   */
  private getSpeed(size: number, time: number): number {
    return Number.parseFloat((size / (time / 1000)).toFixed(2))
  }
}