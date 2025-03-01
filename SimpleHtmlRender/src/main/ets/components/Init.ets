import { Style } from "./VNode";


export function initHtmlRender(params: InitParams) {

  if (params.style) {
    InitParamsStore.defaultStyle = params.style
  } else {
    InitParamsStore.defaultStyle = new Style()
    if (params.backgroundColor) {
      InitParamsStore.defaultStyle.backgroundColor = params.backgroundColor
    }

    if (params.fontSize) {
      InitParamsStore.defaultStyle.fontSize = params.fontSize
    }

    if (params.fontColor) {
      InitParamsStore.defaultStyle.fontColor = params.fontColor
    }

    if (params.hrefFontColor) {
      InitParamsStore.defaultStyle.hrefFontColor = params.hrefFontColor
    }
  }
  if(params.onLinkClick){
    InitParamsStore.onLinkClick = params.onLinkClick
  }

}

class InitParams {
  backgroundColor?: string | Resource | Color
  fontSize?: number
  fontColor?: string | Resource | Color
  hrefFontColor?: string | Resource | Color
  style?: Style
  onLinkClick?: ((link: string) => void)
}

export class InitParamsStore {
  static defaultStyle: Style
  static onLinkClick: ((link: string) => void) | undefined
}