import { fileIo as fs } from '@kit.CoreFileKit';
import { Errors, logger } from 'common';
import { HttpError, HttpExchange } from 'serve';
import { ErrorMessage, FileInfoModel, FileTransferStatus, TransferProgressChangedAction } from '../../model';
import { EventBus, EventType, TransferFileProgressEvent } from '../../eventbus';
import { ArkTSUtils } from '@kit.ArkTS';
import { Dates, FileProvider } from '../../utils';
import { FlushTask } from './FlushTask';

const TAG = 'FlushService'

const DOWNLOAD_FILES_DIR: string = 'received'

export class FlushService {
  private exchange: HttpExchange | null
  private stream: fs.Stream | undefined
  private isFlushing: boolean = false
  private isFinished: boolean = false
  private fileDir: string
  private progress: number = 0
  private fileInfo: FileInfoModel
  private queue: FlushTask[] = []
  private lock_: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock();
  private startMilli: number = 0
  private lastNoticeMilli: number = 0
  private isCanceled: boolean = false

  constructor(exchange: HttpExchange, fileDir: string, fileInfo: FileInfoModel) {
    this.exchange = exchange
    this.fileDir = fileDir
    this.fileInfo = fileInfo
    this.startMilli = Dates.now()
  }

  flush(flush: FlushTask) {
    this.add(flush)
  }

  end() {
    //因为onStream是异步执行的调用onFinish时onStream可以还未执行结束
    //这里用isFinished标记下
    this.isFinished = true
  }

  cancel() {
    this.isCanceled = true
  }

  private async create(): Promise<void> {
    let filePath: string = ''
    try {
      const dir: string = `${this.fileDir}/${DOWNLOAD_FILES_DIR}`
      filePath = `${dir}/${this.fileInfo.fileName}`
      if (!await fs.access(dir, fs.AccessModeType.EXIST)) {
        console.log(`--- 准备创建文件夹: ${dir}`)
        await fs.mkdir(dir)
      }
      this.stream = await fs.createStream(filePath, 'w')
      console.log(`--- 文件创建成功: ${filePath}`)
    } catch (e) {
      console.log(`--- 文件创建失败: ${filePath} ${Errors.getErrorMessage(e)}`)
      this.stream?.close()
      throw HttpError.error(500)
    }
  }

  private async add(flush: FlushTask) {
    await this.lock_.lockAsync(() => this.queue.push(flush), ArkTSUtils.locks.AsyncLockMode.EXCLUSIVE)
    if (this.checkCancel()) {
      return
    }
    if (!this.isFlushing && !this.isCanceled) {
      this.isFlushing = true;
      this.process(this.lastNoticeMilli);
    }
  }

  private async process(lastNotice: number): Promise<void> {
    try {
      let flush: FlushTask | undefined
      await this.lock_.lockAsync(() => flush = this.queue.shift(), ArkTSUtils.locks.AsyncLockMode.EXCLUSIVE)
      if (flush) {
        //向磁盘写入
        await this.flushToDisk(flush);
        if (this.checkCancel()) {
          return
        }
        const elapsed = Dates.consumed(lastNotice)
        if (elapsed > 200) {
          const duration = Dates.consumed(this.startMilli)
          const speed = FileProvider.getTransferSpeed(this.progress, duration)
          console.info(`speed: ${speed} duration: ${duration}`)
          this.postEvent({
            fileId: this.fileInfo.id,
            status: FileTransferStatus.TRANSFERRING,
            progress: this.progress,
            total: this.fileInfo.size,
            speed: speed
          })
          this.lastNoticeMilli = Dates.now()
        }
        if (this.queue.length > 0) {
          await this.process(this.lastNoticeMilli)
          return
        }
      }
    } catch (e) {
      logger.debug(TAG, `文件写入出错: ${Errors.getErrorMessage(e)}`)
      this.exchange!!.writeError(HttpError.error(500))
      this.postEvent({
        fileId: this.fileInfo.id,
        status: FileTransferStatus.ERROR,
        progress: 0,
        total: this.fileInfo.size,
        speed: 0,
        error: e
      })
    }
    this.isFlushing = false; // 任务处理完成
    if (this.isFinished) {
      this.close()
      this.exchange!!.writeJson(new ErrorMessage())
      this.postEvent({
        fileId: this.fileInfo.id,
        status: FileTransferStatus.COMPLETED,
        progress: this.fileInfo.size,
        total: this.fileInfo.size,
        speed: 0
      })
    }
  }

  private async flushToDisk(flush: FlushTask): Promise<number> {
    if (!this.stream) {
      await this.create()
    }
    const length = await this.stream!!.write(flush.buffer)
    if (this.checkCancel()) {
      return 0
    }
    this.progress += length
    // logger.debug(TAG, '文件写入长度: ' + flush.buffer.byteLength +
    //   ` index: ${flush.index} progress: ${flush.buffer.byteLength} 进度: ${((this.progress / this.fileInfo.size) * 100).toFixed(2)}%`)
    return length
  }

  private postEvent(event: TransferProgressChangedAction) {
    EventBus.getInstance().post(EventType.TRANSFER_PROGRESS_CHANGED_ACTION, TransferFileProgressEvent(event))
  }

  private checkCancel(): boolean {
    if (this.isCanceled) {
      this.postEvent({
        fileId: this.fileInfo.id,
        status: FileTransferStatus.CANCELED,
        progress: 0,
        total: this.fileInfo.size,
        speed: 0
      })
      this.close()
      return true
    }
    return false
  }

  private close() {
    this.stream?.close()
    this.stream = undefined
  }
}