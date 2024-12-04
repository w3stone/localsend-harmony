import { hilog } from '@kit.PerformanceAnalysisKit';

export namespace logger {
  export function debug(tag: string = "LocalSend", format: string, ...args: (string | number)[]) {
    hilog.debug(0x0000, tag, format, args)
  }

  export function info(tag: string = "LocalSend", format: string, ...args: (string | number)[]) {
    hilog.info(0x0000, tag, format, args)
  }

  export function warn(tag: string = "LocalSend", format: string, ...args: (string | number)[]) {
    hilog.warn(0x0000, tag, format, args)
  }

  export function error(tag: string = "LocalSend", format: string, ...args: (string | number)[]) {
    hilog.error(0x0000, tag, format, args)
  }

  export function fatal(tag: string = "LocalSend", format: string, ...args: (string | number)[]) {
    hilog.fatal(0x0000, tag, format, args)
  }
}