import { Router, PromptAction } from '@ohos.arkui.UIContext'
import { getGoodsInfo, getImageUrl } from '../api/Shop';
import { Header } from '../components/Header';
import { Goods } from '../models/Shop';
import { add, CartItem } from '../models/Cart';

interface RouterParams {
  goodsId: number
}

@Entry
@Component
struct GoodsInfoPage {
  private router: Router = this.getUIContext().getRouter();
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  @State goodsId: number = 0;
  @State goods: Goods | null = null;

  async aboutToAppear() {
    const routerParams = this.router.getParams() as RouterParams;
    this.goodsId = routerParams.goodsId;
    this.goods = await getGoodsInfo(this.goodsId);
  }

  build() {
    Column() {
      Header({ title: "商品详情", showBack: true, onBack: () => { this.router.back() } })
      if (this.goods == null) {
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
            // 商品大图
            Image(getImageUrl(this.goods!.image + ""))
              .width("100%")
              .height(280)
              .objectFit(ImageFit.Cover)

            // 商品信息卡片
            Column({ space: 10 }) {
              Text(this.goods!.name)
                .fontWeight(FontWeight.Bold)
                .fontSize(20)
                .fontColor("#1A1A1A")
                .width("100%")

              Text(this.goods!.sell_point)
                .fontSize(14)
                .fontColor("#8E8E93")
                .width("100%")

              Row() {
                Text(`¥${this.goods!.price}`)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor("#FF3B30")
                Blank()
                Text(`库存: ${this.goods!.num}`)
                  .fontSize(13)
                  .fontColor("#8E8E93")
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor("#F5F5F5")
                  .borderRadius(10)
              }
              .width("100%")

              Divider().strokeWidth(0.5).color("#E5E5EA")

              Text("商品详情")
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor("#1A1A1A")
                .width("100%")

              Text(this.goods!.content)
                .fontSize(14)
                .fontColor("#666666")
                .lineHeight(22)
                .width("100%")
            }
            .padding(16)
            .backgroundColor("#FFFFFF")
            .borderRadius({ topLeft: 16, topRight: 16 })

            // 底部留白给按钮
            Blank().height(20)
          }
        }
        .layoutWeight(1)
        .backgroundColor("#F5F5F5")
      }

      // 底部操作栏
      if (this.goods != null) {
        Row({ space: 10 }) {
          Button("加入购物车")
            .fontSize(15)
            .fontColor("#007AFF")
            .backgroundColor("#FFFFFF")
            .border({ width: 1, color: "#007AFF" })
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              if (this.goods) {
                const cartItem: CartItem = {
                  goodsId: this.goods.id,
                  name: this.goods.name,
                  image: getImageUrl(this.goods.image),
                  price: this.goods.price,
                  count: 1,
                  selected: true
                };
                add(cartItem);
                this.promptAction.showToast({ message: "已加入购物车" });
                AppStorage.setOrCreate("cartVersion", (AppStorage.get("cartVersion") as number || 0) + 1);
              }
            })
          Button("立即购买")
            .fontSize(15)
            .fontColor("#FFFFFF")
            .backgroundColor("#007AFF")
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)
        }
        .width("100%")
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .backgroundColor("#FFFFFF")
        .border({ width: { top: 0.5 }, color: "#E5E5EA" })
      }
    }
    .width("100%")
    .height("100%")
  }
}
