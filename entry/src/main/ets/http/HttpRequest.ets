import { http } from '@kit.NetworkKit';
import { BaseResponse, ErrorMessage } from '../model';
import { JSON } from '@kit.ArkTS';
import { HttpRequestError } from './HttpRequestError';

interface EmptyInterface {}

enum ContentType {
  APPLICATION_JSON = 'application/json',
  APPLICATION_FORM_URLENCODED = 'application/x-www-form-urlencoded',
  MULTIPART_FORM_DATA = 'multipart/form-data',
}

async function request<T extends BaseResponse>(url: string, method: http.RequestMethod,
  contentType?: ContentType, data?: object | null): Promise<T> {

  try {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let request = http.createHttp();
    const options: http.HttpRequestOptions = {
      method: method, // 可选，默认为http.RequestMethod.GET
      // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定
      // 开发者根据自身业务需要添加header字段
      header: { 'Content-Type': 'application/json' },
      readTimeout: 300000, // 可选，默认为60000ms //5分钟
      connectTimeout: 10000, // 可选，默认为60000ms
      usingProtocol: http.HttpProtocol.HTTP1_1,
      // caPath: '/path/to/cacert.pem', // 可选，默认使用系统预设CA证书，自API 10开始支持该属性
      // clientCert: {
      //   // 可选，默认不使用客户端证书，自API 11开始支持该属性
      //   certPath: '/path/to/client.pem', // 默认不使用客户端证书，自API 11开始支持该属性
      //   keyPath: '/path/to/client.key', // 若证书包含Key信息，传入空字符串，自API 11开始支持该属性
      //   certType: http.CertType.PEM, // 可选，默认使用PEM，自API 11开始支持该属性
      //   keyPassword: "passwordToKey" // 可选，输入key文件的密码，自API 11开始支持该属性
      // },
      // certificatePinning: [// 可选，支持证书锁定配置信息的动态设置，自API 12开始支持该属性
      //   {
      //     publicKeyHash: 'Pin1', // 由应用传入的证书PIN码，自API 12开始支持该属性
      //     hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性
      //   },
      //   {
      //     publicKeyHash: 'Pin2', // 由应用传入的证书PIN码，自API 12开始支持该属性
      //     hashAlgorithm: 'SHA-256' // 加密算法，当前仅支持SHA-256，自API 12开始支持该属性
      //   }
      // ],
    }
    if (method === http.RequestMethod.POST) {
      options.extraData = data || {} as EmptyInterface
      options.header = { 'Content-Type': contentType?.valueOf() || 'application/json' }
    }
    const resp = await request.request(url, options);
    if (resp.responseCode == 200 && resp.result) {
      const result: T = JSON.parse(resp.result as string) as T
      return Promise.resolve(result)
    } else {
      let message: string = ''
      if (resp.result) {
        const result = JSON.parse(resp.result as string) as ErrorMessage
        message = result.message
      }
      return Promise.reject(new HttpRequestError(resp.responseCode, message))
    }
  } catch (e) {
    return Promise.reject(e)
  }
}

export class HttpRequest {
  static async get<T extends BaseResponse>(url: string): Promise<T> {
    return request(url, http.RequestMethod.GET)
  }

  static async post<T extends BaseResponse>(url: string, data: object | null, contentType?: ContentType): Promise<T> {
    return request(url, http.RequestMethod.POST, contentType, data)
  }
}