import { getCategories, getGoodsList, getSwiperList, getImageUrl } from "../api/Shop";
import { Header } from "./Header";
import { Category, Goods, SwiperItem } from "../models/Shop"
import { Router } from "@kit.ArkUI";

@Component
export struct Shop {
  private router: Router = this.getUIContext().getRouter();
  @State swiperList: SwiperItem[] = [];
  @State categories: Category[] = [];
  @State current1: number = 0;
  @State current2: number = 0;
  @State goodsList: Goods[] = [];

  async aboutToAppear() {
    this.swiperList = await getSwiperList();
    this.categories = await getCategories();
    if (this.categories.length > 0 && this.categories[this.current1].sub.length > 0) {
      this.goodsList = await getGoodsList(this.categories[this.current1].sub[this.current2].id);
    }
  }

  build() {
    Column() {
      Header({ title: "线上商城" })
      Column() {
        // 轮播图
        // if (this.swiperList.length > 0) {
        //   Swiper() {
        //     ForEach(this.swiperList, (item: SwiperItem) => {
        //       Image(getImageUrl(item.img))
        //         .width("100%")
        //         .height(160)
        //         .borderRadius(8)
        //     })
        //   }
        //   .autoPlay(true)
        //   .interval(3000)
        //   .indicator(true)
        //   .width("100%")
        //   .height(160)
        //   .margin({ top: 8, bottom: 8, left: 10, right: 10 })
        // }

        // 一级分类横向滚动
        Scroll() {
          Row({ space: 0 }) {
            ForEach(this.categories, (item: Category, index: number) => {
              Text(item.name)
                .fontSize(14)
                .fontColor(this.current1 == index ? "#007AFF" : "#666666")
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .onClick(() => {
                  this.current1 = index;
                  this.current2 = 0;
                  this.loadGoods();
                })
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width("100%")
        .padding({ top: 4, bottom: 4 })
        .border({ width: { bottom: 0.5 }, color: "#E5E5EA" })

        // 二级分类横向滚动
        if (this.categories.length > 0 && this.categories[this.current1].sub.length > 0) {
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.categories[this.current1].sub, (sitem: Category, index: number) => {
                Text(sitem.name)
                  .fontSize(12)
                  .fontColor(this.current2 == index ? "#FFFFFF" : "#666666")
                  .backgroundColor(this.current2 == index ? "#007AFF" : "#F5F5F5")
                  .borderRadius(14)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .onClick(() => {
                    this.current2 = index;
                    this.loadGoods();
                  })
              })
            }
            .padding({ left: 10, right: 10 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width("100%")
          .padding({ top: 8, bottom: 8 })
        }

        // 商品列表
        Scroll() {
          List({ space: 10 }) {
            ForEach(this.goodsList, (goods: Goods) => {
              ListItem() {
                Row() {
                  Image(goods.image)
                    .width(100)
                    .height(100)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                  Column() {
                    Text(goods.name)
                      .fontWeight(FontWeight.Bold)
                      .fontSize(16)
                      .fontColor("#1A1A1A")
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(goods.sell_point)
                      .fontSize(12)
                      .fontColor("#8E8E93")
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Blank()
                    Row() {
                      Text(`¥${goods.price}`)
                        .fontColor("#FF3B30")
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                      Blank()
                      Text(`库存 ${goods.num}`)
                        .fontSize(11)
                        .fontColor("#8E8E93")
                    }
                    .width("100%")
                  }
                  .layoutWeight(1)
                  .height(100)
                  .margin({ left: 10 })
                  .alignItems(HorizontalAlign.Start)
                }
                .width("100%")
                .padding(10)
                .backgroundColor("#FFFFFF")
                .borderRadius(12)
                .onClick(() => {
                  this.router.pushUrl({
                    url: "pages/GoodsInfoPage",
                    params: { goodsId: goods.id }
                  });
                })
              }
            })
          }
          .width("100%")
          .padding({ left: 10, right: 10, bottom: 10 })
          .constraintSize({
            minHeight: "100%"
          })
        }
        .layoutWeight(1)
      }
      .layoutWeight(1)
      .backgroundColor("#F5F5F5")
    }
    .width("100%")
    .height("100%")
  }

  async loadGoods() {
    if (this.categories.length > 0 &&
        this.categories[this.current1] &&
        this.categories[this.current1].sub.length > 0) {
      const sub = this.categories[this.current1].sub[this.current2];
      if (sub) {
        this.goodsList = await getGoodsList(sub.id);
      }
    }
  }
}
