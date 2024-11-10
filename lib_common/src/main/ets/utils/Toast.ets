import promptAction from '@ohos.promptAction';

export namespace toast {
  export function show(message: string | Resource) {
    promptAction.showToast({ message: message })
  }
}