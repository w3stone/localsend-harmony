import { ReceiveResultActionType } from './'

/**
 * emit event data
 */
export interface ReceiveResultAction {
  action: ReceiveResultActionType
  /**
   *  HTTP code  Message
   *  204  Finished (No file transfer needed)
   *  400  Invalid body
   *  401  PIN required / Invalid PIN
   *  403  Rejected
   *  409  Blocked by another session
   *  429  Too many requests
   *  500  Unknown error by receiver
   */
  code: number | undefined
  message: string | undefined //action=Error时的错误信息
}