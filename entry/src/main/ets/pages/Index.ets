import { HtmlRender, Style, VNode } from 'simplehtmlrender'
import { promptAction } from '@kit.ArkUI'
import { HashMap } from '@kit.ArkTS'
import { hilog } from '@kit.PerformanceAnalysisKit'

@Entry
@Component
struct Index {
  private htmlContent: string =
    '<span style="color:blue;background:yellow" margin="left:10;right:10">这位姑娘有一双  <span style="color:blue;background:red" font-weight="10">蓝<span style="color:red;background:blue">色</span></span>的眼睛</span> <a href="https://example.com">这是链接</a>'

  build() {
    Column() {
      Text('富文本内容').width('100%').textAlign(TextAlign.Start)
      Text(this.htmlContent).padding(10).borderRadius(6).backgroundColor("#e7e7e7").margin(10)
      Divider().vertical(false).color(Color.Gray).height(2).margin(15)
      Text('默认效果').width('100%').textAlign(TextAlign.Start)
      HtmlRender({htmlContent:this.htmlContent}).margin(10)
      Divider().vertical(false).color(Color.Gray).height(2).margin(15)
      Text('自定义默认属性值').width('100%').textAlign(TextAlign.Start)
      HtmlRender({htmlContent:this.htmlContent,defaultStyle:{fontSize:14,hrefFontColor:Color.Red,fontColor:Color.Brown} as Style, onLinkClick:(link:string)=>{
        promptAction.showToast({message:`点击了链接 ${link}`})
      }}).margin(10)
      Divider().vertical(false).color(Color.Gray).height(2).margin(15)
      Text('自定义展示效果').width('100%').textAlign(TextAlign.Start)
      HtmlRender({ htmlContent: this.htmlContent, builder: this.buildHtml }).margin(10)
    }

  }

  @Builder
  buildHtml(vNode: VNode) {
    Text() {
      ForEach(vNode.child, (child: VNode) => {

        if (child.style.backgroundColor != Color.Transparent) {
          ContainerSpan() {
            if (child.style.href) {
              Span(child.text).configSpanStyle(child).onClick((_) => {
                promptAction.showToast({ message: child.style.href })
              }).fontColor(Color.Green)
            } else {
              Span(child.text).configSpanStyle(child).margin(20)
            }

          }.textBackgroundStyle({ color: child.style.backgroundColor })
        } else {
          if (child.style.href) {
            Span(child.text).configSpanStyle(child).onClick((_) => {
              promptAction.showToast({ message: child.style.href })
            }).fontColor(Color.Green).margin(20)
          } else {
            Span(child.text).configSpanStyle(child)
          }
        }
      })
    }
  }
}

@Extend(Span)
function configSpanStyle(vNode: VNode) {
  .backgroundColor(vNode.style.backgroundColor)
  .fontColor(vNode.style.href ? vNode.style.hrefFontColor : vNode.style.fontColor)
  .fontSize(vNode.style.fontSize)
}
