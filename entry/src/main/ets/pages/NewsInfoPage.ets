import { Router } from '@ohos.arkui.UIContext'
import { getNewsInfo } from '../api/News';
import { Header } from '../components/Header';
import { NewsInfo } from '../models/News';

interface RouterParams {
  newsId: number
}

@Entry
@Component
struct NewsInfoPage {
  private router: Router = this.getUIContext().getRouter();
  @State newsId: number = 0;
  @State news: NewsInfo | null = null;

  async aboutToAppear() {
    const routerParams = this.router.getParams() as RouterParams;
    this.newsId = routerParams.newsId;
    this.news = await getNewsInfo(this.newsId);
  }

  build() {
    Column() {
      Header({ title: "新闻详情", showBack: true, onBack: () => { this.router.back() } })
      if (this.news == null) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color("#007AFF")
          Text("加载中...")
            .fontSize(14)
            .fontColor("#8E8E93")
            .margin({ top: 10 })
        }
        .width("100%")
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor("#F5F5F5")
      } else {
        Scroll() {
          Column({ space: 12 }) {
            Text(this.news!.title)
              .fontWeight(FontWeight.Bold)
              .fontSize(20)
              .fontColor("#1A1A1A")
              .width("100%")

            Row() {
              Text(`👁 ${this.news!.click} 次阅读`)
                .fontSize(12)
                .fontColor("#8E8E93")
            }
            .width("100%")

            Divider().strokeWidth(0.5).color("#E5E5EA")

            RichText(this.news!.content)
              .width("100%")
          }
          .padding(16)
          .backgroundColor("#FFFFFF")
          .borderRadius(0)
        }
        .layoutWeight(1)
        .backgroundColor("#F5F5F5")
      }
    }
    .width("100%")
    .height("100%")
  }
}
