import { ThemeProvider } from '../../../../theme/ThemeProvider'
import { ConfigurationConstant } from '@kit.AbilityKit'

@Builder
export function ThemeMenu() {
  Menu() {
    MenuItem({ content: $r('app.string.flow_system') }).onClick(() => ThemeProvider.setThemeModel(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET))
    MenuItem({ content: $r('app.string.light') }).onClick(() => ThemeProvider.setThemeModel(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))
    MenuItem({ content: $r('app.string.dark') }).onClick(() => ThemeProvider.setThemeModel(ConfigurationConstant.ColorMode.COLOR_MODE_DARK))
  }
  .fontColor($r('app.color.on_container'))
}