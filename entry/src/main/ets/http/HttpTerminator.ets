import { Terminator } from "./Terminator";
import { http } from "@kit.NetworkKit";

export class HttpTerminator implements Terminator {
  http: http.HttpRequest | null = null

  constructor(http: http.HttpRequest) {
    this.http = http
  }

  terminate(): void {
    this.http?.destroy()
    this.http = null
  }
}