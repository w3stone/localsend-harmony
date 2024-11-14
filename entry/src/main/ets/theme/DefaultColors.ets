import { Colors, CustomColors } from "@kit.ArkUI";

export class DefaultColors implements CustomColors {
  brand?: ResourceColor | undefined = $r('app.color.primary')
  fontPrimary?: ResourceColor | undefined = $r('app.color.primary')
  backgroundPrimary?: ResourceColor | undefined = $r('app.color.background')
}

export class DefaultThemes implements CustomTheme {
  colors?: Partial<Colors> | undefined

  constructor() {
    this.colors = new DefaultColors()
  }
}