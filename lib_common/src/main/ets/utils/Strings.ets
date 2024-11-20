import { buffer, util } from '@kit.ArkTS';
import { Context } from '@kit.AbilityKit';

export class Strings {
  private constructor() {
  }

  static buf2String(buf: ArrayBuffer): string {
    let msgArray: Uint8Array = new Uint8Array(buf);
    let textDecoder: util.TextDecoder = util.TextDecoder.create("utf-8");
    return textDecoder.decodeToString(msgArray)
  }


  static FORMAT_PLACEHOLDER = /%s/

  static formatString(format: string, ...args: string[]) {
    let result = format
    args.forEach(value => {
      result = result.replace(Strings.FORMAT_PLACEHOLDER, value)
    })
    return result
  }

  /**
   * 将指定字符串按指定字符数分割
   * @param array 用于接收返回数据数组，传空数组
   * @param str 用于分割的数组
   * @param len 分割长度
   * @returns
   */
  static getSliceByBytes(array: string[], str: string, len: number): string[] {
    if (!str) {
      return []
    }
    const size: number = buffer.byteLength(str, 'utf-8')
    if (size < len) {
      array.push(str)
      return array
    }
    let currentSize = 0;
    let lastCharLen = 0
    let subEnd = 0
    for (subEnd = 0; subEnd < str.length; subEnd++) {
      lastCharLen = ((str.charCodeAt(subEnd) > 255) ? 2 : 1)
      currentSize += lastCharLen
      if (currentSize >= len) {
        array.push(str.substring(0, subEnd + 1))
        break;
      }
    }
    if (currentSize < size) {
      Strings.getSliceByBytes(array, str.slice(subEnd + parseInt((lastCharLen / 2).toFixed())), len)
    }
    return array
  }

  static getString(context: Context, resourse: Resource): string {
    return context.resourceManager.getStringSync(resourse)
  }
}
