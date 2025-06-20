import { promptAction } from '@kit.ArkUI'
import { HtmlRender, Style, VNode } from '../Index'
import { initHtmlRender } from '../src/main/ets/components/Init'

@Entry
@Component
struct Index {
  private htmlContent: string =
    '<span style="color:blue;background:yellow" margin="left:10;right:10">这位<br/>姑<img src="https://alliance-communityfile-drcn.dbankcdn.com/FileServer/getFile/cmtyPub/011/111/111/0000000000011111111.20241101135748.69421330215182784913343800879033:50001231000000:2800:61A18C700942863FE77A8A307601C6E347B7A582DD8B5E0C401BFB7471D2843C.png?needInitFileName=true?needInitFileName=true" />娘有<p>一双</p>  <span style="color:blue;background:red" font-weight="10">蓝<span style="color:red;background:blue">色</span></span>的眼睛</span> <a href="https://example.com">这是链接</a>'


  aboutToAppear(): void {
    initHtmlRender({
      onLinkClick: (href:string)=>{promptAction.showToast({message:`点击了 ${href}`})},
      backgroundColor:Color.Red,
      fontColor:"#323232",
      fontSize:14,
      hrefFontColor:"#661b91e0"
    })
  }

  build() {
    Column() {
      Text('富文本内容').width('100%').textAlign(TextAlign.Start)
      Text(this.htmlContent).padding(10).borderRadius(6).backgroundColor("#e7e7e7").margin(10)
      Divider().vertical(false).color(Color.Gray).height(2).margin(15)
      Text('默认效果').width('100%').textAlign(TextAlign.Start)
      HtmlRender({htmlContent:this.htmlContent}).margin(10)
      Divider().vertical(false).color(Color.Gray).height(2).margin(15)

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
