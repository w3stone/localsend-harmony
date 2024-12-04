import assertThrowError from '@ohos/hypium/src/main/module/assert/assertThrowError'

export class IpAddress {

   isIpv4Address(ip: string): boolean {
    if (!ip) {
      return false
    }
    let lines: Array<String> = ip.split(".")
    if (lines.length != 4) {
      return false
    }
    for (let pattern of lines) {
      try {
        let number = Number.parseInt(pattern.toString())
        if (number >= 0 && number <= 255) {
          continue
        } else {
          return false
        }
      } catch (e) {
        return false
      }
    }
    return true
  }

  ip2int(ip: string): number {
    assertThrowError(this.isIpv4Address(ip), true)
    let result = 0;
    let lines: Array<string> = ip.split(".");
    for (let pattern of lines) {
      let number = Number.parseInt(pattern);
      result = number | (result << 8);
    }
    return result;
  }

  int2ip(intIp: number): string {
    return ((intIp >> 24) & 0xff) + "." + ((intIp >> 16) & 0xff) + "." + ((intIp >> 8) & 0xff) + "." + (intIp & 0xff);
  }
}