import { util } from '@kit.ArkTS';
import { CryptoUtil } from '@pura/harmony-utils';

export class SessionProvider {
  static generateSessionId(): string {
    return util.generateRandomUUID()
  }

  static generateToken(session: string, fileId: string): string {
    // return CryptoUtil.digestSync(`${session}${fileId}`, 'MD5')
    return util.generateRandomUUID()
  }
}