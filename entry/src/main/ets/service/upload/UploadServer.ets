import { socket } from '@kit.NetworkKit';
import { FileInfoModel, FileTransferStatus } from '../../model';
import { fileIo as fs } from '@kit.CoreFileKit';
import { logger, Errors } from 'common';
import { buffer } from '@kit.ArkTS';
import { FileProvider } from '../../utils';
import { HttpProtocol } from './HttpProtocol';
import { TransferException } from './TransferException';
import { Terminator } from './Terminator';

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
      let length: number = await fs.read(file.fd, input, { offset: readSize, length: MAX_READ_LENGTH })
      readSize += length
      await this.sendChunked(url, info.size, input, info.fileType, false)
      callback(FileTransferStatus.TRANSFERRING, readSize, info.size, info.id)
      //分片向服务器发送二进制流
      while (length > 0) {
        //上传被终止
        if (this.terminated) {
          break
        }
        input = new ArrayBuffer(MAX_READ_LENGTH)
        length = await fs.read(file.fd, input, { offset: readSize, length: MAX_READ_LENGTH })
        readSize += length
        await this.sendChunked(url, info.size, (length < MAX_READ_LENGTH) ? input.slice(0, length) : input, info.fileType, true)
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