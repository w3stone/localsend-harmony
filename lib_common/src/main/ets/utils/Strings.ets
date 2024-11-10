import { util } from "@kit.ArkTS";

export function buf2String(buf: ArrayBuffer): string {
  let msgArray: Uint8Array = new Uint8Array(buf);
  let textDecoder: util.TextDecoder = util.TextDecoder.create("utf-8");
  return textDecoder.decodeToString(msgArray)
}

const FORMAT_PLACEHOLDER = /%s/

export function formatString(format: string, ...args: string[]) {
  let result = format
  args.forEach(value => {
    result = result.replace(FORMAT_PLACEHOLDER, value)
  })
  return result
}