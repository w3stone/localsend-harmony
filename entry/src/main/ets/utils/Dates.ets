export class Dates {
  private constructor() {
  }

  static now(): number {
    return new Date().getTime()
  }

  /**
   * 返回当前时间戳与给定的时间戳相差的时间
   * @param mill
   * @returns
   */
  static consumed(mill: number): number {
    return new Date().getTime() - mill
  }

  /**
   * 将秒转换为时间
   * @param sec
   * @returns
   */
  static getSecondsToTime(sec: number) {
    const seconds = Math.floor(sec) % 60;
    const minutes = Math.floor(sec / 60) % 60;
    const hours = Math.floor(sec / (60 * 60)) % 24;
    const days = Math.floor(sec / (60 * 60 * 24));
    let time: string = ''
    if (days > 0) {
      time += `${days}:`
    }
    if (hours > 0) {
      time += `${hours.toString().padStart(2, '0')}:`
    }
    time += `${minutes.toString().padStart(2, '0')}:`
    time += `${seconds.toString().padStart(2, '0')}`
    return time
  }

  static delay(ms: number): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve()
      }, ms)
    })
  }
}