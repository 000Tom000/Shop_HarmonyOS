import { Router } from "@ohos.arkui.UIContext";
import { getNewsList } from "../api/News";
import { getSwiperList, getImageUrl } from "../api/Shop";
import { New } from "../models/News";
import { SwiperItem } from "../models/Shop";
import { Header } from "./Header";

@Component
export struct News {
  private router: Router = this.getUIContext().getRouter();

  @State swiperList: SwiperItem[] = [];
  @State newsList: New[] = [];

  async aboutToAppear() {
    this.swiperList = await getSwiperList();
    this.newsList = await getNewsList();
  }

  build() {
    Column() {
      Header({ title: "实时新闻" })
      Scroll() {
        Column({ space: 10 }) {
          // 轮播图
          if (this.swiperList.length > 0) {
            Swiper() {
              ForEach(this.swiperList, (item: SwiperItem) => {
                Image(item.img)
                  .width("100%")
                  .height(160)
                  .borderRadius(10)
              })
            }
            .autoPlay(true)
            .interval(3000)
            .indicator(true)
            .width("100%")
            .height(160)
            .margin({ top: 8, left: 10, right: 10 })
          }

          // 新闻列表
          ForEach(this.newsList, (item: New) => {
            Row() {
              Image(item.img_url)
                .width(100)
                .height(75)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
              Column() {
                Text(item.title)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor("#1A1A1A")
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(item.zhaiyao)
                  .fontSize(12)
                  .fontColor("#8E8E93")
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 4 })
                Blank()
                Row() {
                  Text(`👁 ${item.click}`)
                    .fontSize(11)
                    .fontColor("#C7C7CC")
                }
                .width("100%")
              }
              .layoutWeight(1)
              .height(75)
              .margin({ left: 10 })
              .alignItems(HorizontalAlign.Start)
            }
            .width("100%")
            .padding(10)
            .backgroundColor("#FFFFFF")
            .borderRadius(12)
            .onClick(() => {
              this.router.pushUrl({
                url: "pages/NewsInfoPage",
                params: { newsId: item.id }
              })
            })
          })
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 10 })
      }
      .layoutWeight(1)
      .backgroundColor("#F5F5F5")
    }
    .width("100%")
    .height("100%")
  }
}
