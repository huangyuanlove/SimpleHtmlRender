import { copyStyle, Style, VNode } from "./VNode"
import { util, xml } from "@kit.ArkTS";
import { Stack } from '@kit.ArkTS';
import hilog from "@ohos.hilog";
import { InitParamsStore } from "./Init";

const SUPPORT_TAG: string[] = ['font', 'span', 'a', 'br', 'img', 'p']

@ComponentV2
export struct HtmlRender {
  @Require @Param htmlContent: string = ''
  defaultStyle: Style | undefined
  onLinkClick: ((link: string) => void) | undefined
  rootNode: VNode = new VNode()
  private styleStack: Stack<Style> = new Stack()
  @BuilderParam builder: (vNode: VNode) => void | null
  @Local hasParse: boolean = false
  //改变该值触发更新
  @Local refresh: boolean = false

  aboutToAppear(): void {
    //如果没有传入默认样式，则使用初始化方法中传入的样式
    if (!this.defaultStyle) {
      this.defaultStyle = InitParamsStore.defaultStyle
    }
    this.startParse()
  }

  @Monitor('htmlContent')
  onHtmlContentChange(monitor: IMonitor) {
    this.startParse()
  }

  startParse() {

    this.refresh = !this.refresh
    this.hasParse = false
    this.rootNode = new VNode()
    this.styleStack = new Stack()

    let content: string = `<span>${this.htmlContent}</span>`
    let textEncoder: util.TextEncoder = new util.TextEncoder();
    let arrBuffer: Uint8Array = textEncoder.encodeInto(content);

    let xmlPullParser: xml.XmlPullParser = new xml.XmlPullParser(arrBuffer.buffer as object as ArrayBuffer, 'UTF-8');
    let options: xml.ParseOptions = {
      supportDoctype: true,
      ignoreNameSpace: true,
      // attributeValueCallbackFunction:this.attributeValueCallback.bind(this),
      // tokenValueCallbackFunction: this.tokenValueCallback.bind(this)
      attributeValueCallbackFunction:(name:string,value:string)=>{
        return this.attributeValueCallback(name,value)
      },
      tokenValueCallbackFunction:(name: xml.EventType, value: xml.ParseInfo)=>{
        return this.tokenValueCallback(name,value)
      }
    };
    try {
      xmlPullParser.parseXml(options);
      this.hasParse = true
    } catch (error) {
      hilog.error(0x01, 'HtmlRender', `parse error==> ${(error as Object).toString()}`)
      this.hasParse = true
    }


  }

  attributeValueCallback(name: string, value: string): boolean {
    let topStyle: Style = this.styleStack.peek()
    if (!topStyle) {
      return true
    }


    if (name === 'href') {
      topStyle.href = value
    } else if (name === 'size') {
      if (value.includes('px')) {
        let tmp = value.replace('px', '')
        topStyle.fontSize = px2fp(parseInt(tmp))
      } else {
        topStyle.fontSize = px2fp(parseInt(value))
      }
    } else if (name === 'style') {
      let attributes: string[] = value.split(';')
      attributes.forEach((attribute: string) => {
        let tmp: string [] = attribute.split(':')
        if (tmp[0] === 'color') {
          topStyle.fontColor = this.getColorWithStr(tmp[1])
        } else if (tmp[0] === 'background') {
          topStyle.backgroundColor = this.getColorWithStr(tmp[1])
        } else if (tmp[0] === 'font-size') {
          topStyle.fontSize = px2fp(parseInt(tmp[1].replace('px', '')))
        }
      })
    } else if (name === 'color') {
      topStyle.fontColor = this.getColorWithStr(value)
    } else if (name === 'src') {
      topStyle.src = value
    }
    return true; // true:继续解析 false:停止解析
  }

  getColorWithStr(color: string): string | Color {
    if (color.includes('#')) {
      return color
    }
    switch (color.toLowerCase()) {
      case 'white':
        return Color.White
      case 'black':
        return Color.Black
      case 'blue':
        return Color.Blue
      case 'brown':
        return Color.Brown
      case 'gray':
        return Color.Gray
      case 'green':
        return Color.Green
      case 'grey':
        return Color.Grey
      case 'orange':
        return Color.Orange
      case 'pink':
        return Color.Pink
      case 'red':
        return Color.Red
      case 'yellow':
        return Color.Yellow
      case 'transparent':
        return Color.Transparent
      default:
        return Color.Transparent

    }
  }

  getTagEventName(name: xml.EventType): string {
    let nameStr = ''
    if (name == xml.EventType.START_TAG) {
      nameStr = 'START_TAG'
    } else if (name == xml.EventType.END_TAG) {
      nameStr = 'END_TAG'
    } else if (name == xml.EventType.TEXT) {
      nameStr = 'TEXT'
    }
    return nameStr
  }

  tokenValueCallback(name: xml.EventType, value: xml.ParseInfo): boolean {
    //只需要关心 START_TAG  END_TAG TEXT 这三个类型就好
    if (name == xml.EventType.START_TAG || name == xml.EventType.END_TAG || name == xml.EventType.TEXT) {
    } else {
      return true
    }

    if (name === xml.EventType.TEXT) {
      let vNode: VNode = new VNode()
      vNode.text = value.getText()
      vNode.style = copyStyle(this.styleStack.peek())
      this.rootNode.child?.push(vNode)
    }

    if (name === xml.EventType.START_TAG) {

      if (value.getName() === 'br' || value.getName() === 'p') {
        let lineBreakSpan = new VNode()
        if (value.getName() === 'br') {
          lineBreakSpan.text = '\n'
        } else if (value.getName() === 'p') {
          //暂且将 p 标签当作两个换行处理
          lineBreakSpan.text = '\n\n'

        }
        this.rootNode.child?.push(lineBreakSpan)
      }
      if (SUPPORT_TAG.includes(value.getName())) {
        if (this.styleStack.isEmpty()) {
          let stype = copyStyle(this.defaultStyle)
          this.styleStack.push(stype)
        } else {
          let style = copyStyle(this.styleStack.peek())
          this.styleStack.push(style)
        }
      }

    }
    if (name === xml.EventType.END_TAG && (SUPPORT_TAG.includes(value.getName()))) {
      let style = this.styleStack.pop()
      if (value.getName() === 'img') {
        let vNode: VNode = new VNode()
        vNode.style = style
        this.rootNode.child?.push(vNode)
      } else if (value.getName() === 'p') {

        let lineBreakSpan = new VNode()
        //暂且将 p 标签当作两个换行处理
        lineBreakSpan.text = '\n\n'
        this.rootNode.child?.push(lineBreakSpan)

      }

    }

    return true; //true:继续解析 false:停止解析
  }

  build() {
    if (this.hasParse) {
      if (this.refresh) {
        if (this.builder) {
          this.builder(this.rootNode)
        } else {
          this.buildWithVNode(this.rootNode)
        }

      } else {
        if (this.builder) {
          this.builder(this.rootNode)
        } else {
          this.buildWithVNode(this.rootNode)
        }

      }

    } else {
      LoadingProgress()
        .color(Color.Blue).width(10).height(10)

    }
  }

  @Builder
  buildWithVNode(vNode: VNode) {
    Text() {
      ForEach(vNode.child, (child: VNode) => {
        if (child.style.backgroundColor != Color.Transparent) {
          ContainerSpan() {
            if (child.style.href) {
              Span(child.text).configSpanStyle(child).backgroundColor(vNode.style.backgroundColor).onClick((_) => {
                if (child.style.href) {
                  if (this.onLinkClick) {
                    //优先调用传入的点击方法
                    this.onLinkClick(child.style.href)
                  } else if (InitParamsStore.onLinkClick) {
                    //其次调用传入的点击方法
                    InitParamsStore.onLinkClick(child.style.href)
                  } else {
                    //pass 没有任何处理
                  }
                }


              })
            } else if (child.style.src) {
              ImageSpan(child.style.src).objectFit(ImageFit.Auto).height(child.style.fontSize)
            } else {
              Span(child.text).configSpanStyle(child).backgroundColor(vNode.style.backgroundColor)
            }

          }.textBackgroundStyle({ color: child.style.backgroundColor })
        } else {
          if (child.style.href) {
            Span(child.text).configSpanStyle(child).backgroundColor(vNode.style.backgroundColor).onClick((_) => {
              if (child.style.href) {
                if (this.onLinkClick) {
                  //优先调用传入的点击方法
                  this.onLinkClick(child.style.href)
                } else if (InitParamsStore.onLinkClick) {
                  //其次调用传入的点击方法
                  InitParamsStore.onLinkClick(child.style.href)
                } else {
                  //pass 没有任何处理
                }
              }
            })
          } else if (child.style.src) {
            ImageSpan(child.style.src).objectFit(ImageFit.Auto).height(child.style.fontSize)
          } else {
            Span(child.text).configSpanStyle(child).backgroundColor(vNode.style.backgroundColor)
          }
        }
      })
    }
  }
}

@Extend(Span)
function configSpanStyle(vNode: VNode) {

  .fontColor(vNode.style.href ? vNode.style.hrefFontColor : vNode.style.fontColor)
  .fontSize(vNode.style.fontSize)

}
