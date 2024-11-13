import { util } from "@kit.ArkTS";

export class SessionProvider {
  static generateSessionId(): string {
    return util.generateRandomUUID()
  }
}