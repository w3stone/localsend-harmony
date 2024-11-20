import { http } from '@kit.NetworkKit'
import { logger } from 'common'
import { StringPair } from '../model'
import { JSON } from '@kit.ArkTS'

const TAG = 'HttpLogging'

export class HttpLogging {
  static print(url: String, options: http.HttpRequestOptions) {
    if (options.method) {
    }
    HttpLogging.log(`---> ${options.method} ${url} ${options.usingProtocol?.toString()}\n`)
    if (options.header) {
      for (const entries of Object.entries<string>(options.header as StringPair)) {
        HttpLogging.log(`${entries[0]}: ${entries[1]}`)
      }
    }
    if (options.extraData) {
      HttpLogging.log(`${JSON.stringify(options.extraData)}`)
    }
  }

  static log(message: string) {
    logger.info(TAG, message)
  }
}