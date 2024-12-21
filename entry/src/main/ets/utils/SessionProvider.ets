import { util } from '@kit.ArkTS';

export class SessionProvider {
  static generateSessionId(): string {
    return util.generateRandomUUID()
  }

  static generateToken(session: string, fileId: string): string {
    return util.generateRandomUUID()
  }
}