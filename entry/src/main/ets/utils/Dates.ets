export class Dates {
  private constructor() {
  }

  static now(): number {
    return new Date().getTime()
  }

  static consumed(mill: number): number {
    return new Date().getTime() - mill
  }
}