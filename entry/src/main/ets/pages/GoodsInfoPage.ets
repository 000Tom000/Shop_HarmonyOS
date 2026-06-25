import { Router, PromptAction } from '@ohos.arkui.UIContext'
import { getGoodsInfo, getImageUrl } from '../api/Shop';
import { Header } from '../components/Header';
import { Goods } from '../models/Shop';
import { add, CartItem } from '../models/Cart';
import { getDefaultAddress } from '../api/Address';
import { createOrder } from '../api/Order';
import { CreateOrderGoods, CreateOrderRequest } from '../models/Order';
import { User } from '../api/User';

interface RouterParams {
  goodsId: number
}

@Entry
@Component
struct GoodsInfoPage {
  private router: Router = this.getUIContext().getRouter();
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  @StorageLink("user") user: User | null = null;
  @State goodsId: number = 0;
  @State goods: Goods | null = null;
  @State buyNowLoading: boolean = false;
  // 数量选择面板
  @State showBuyPanel: boolean = false;
  @State buyQuantity: number = 1;

  async aboutToAppear() {
    const routerParams = this.router.getParams() as RouterParams;
    this.goodsId = routerParams.goodsId;
    this.goods = await getGoodsInfo(this.goodsId);
  }

  getTotalPrice(): string {
    if (!this.goods) {
      return "0.00";
    }
    return (parseFloat(this.goods.price) * this.buyQuantity).toFixed(2);
  }

  // 显示数量选择面板
  showBuyNowPanel() {
    if (!this.goods) {
      return;
    }
    this.buyQuantity = 1;
    this.showBuyPanel = true;
  }

  // 关闭面板
  dismissBuyPanel() {
    this.showBuyPanel = false;
  }

  // 确认购买
  doBuyNowConfirm() {
    this.showBuyPanel = false;
    this.handleBuyNow(this.buyQuantity);
  }

  // 创建订单
  async handleBuyNow(quantity: number) {
    // 1. 检查登录
    if (!this.user) {
      this.promptAction.showToast({ message: "请先登录" });
      setTimeout(() => {
        this.router.pushUrl({ url: "pages/LoginPage" });
      }, 500);
      return;
    }

    if (!this.goods) {
      return;
    }

    // 2. 获取默认收货地址
    this.buyNowLoading = true;
    const address = await getDefaultAddress();
    if (!address) {
      this.buyNowLoading = false;
      AlertDialog.show({
        title: "提示",
        message: "请先添加收货地址",
        autoCancel: true,
        alignment: DialogAlignment.Center,
        primaryButton: { value: "取消", action: () => {} },
        secondaryButton: {
          value: "去添加",
          action: () => {
            this.router.pushUrl({ url: "pages/AddressManagePage" });
          }
        }
      });
      return;
    }

    // 3. 计算总价
    const totalPrice = (parseFloat(this.goods.price) * quantity).toFixed(2);

    // 4. 确认下单弹框
    AlertDialog.show({
      title: "确认下单",
      message: `商品：${this.goods.name}\n数量：${quantity}件\n单价：¥${this.goods.price}\n合计：¥${totalPrice}\n\n收货地址：${address.area} ${address.detail}\n收货人：${address.name} ${address.tel}`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: "取消",
        action: () => {
          this.buyNowLoading = false;
        }
      },
      secondaryButton: {
        value: "确认下单",
        action: async () => {
          try {
            const goods: CreateOrderGoods[] = [{
              id: this.goods!.id.toString(),
              count: quantity,
              selected: true
            }];
            const req: CreateOrderRequest = {
              address: address.id,
              goods: goods,
              note: ""
            };
            const msg = await createOrder(req);
            this.promptAction.showToast({ message: msg || "下单成功" });
          } catch (e) {
            this.promptAction.showToast({ message: "下单失败，请重试" });
          } finally {
            this.buyNowLoading = false;
          }
        }
      }
    });
  }

  build() {
    Stack() {
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
              .backgroundColor(this.buyNowLoading ? "#7EB8FF" : "#007AFF")
              .borderRadius(22)
              .height(44)
              .layoutWeight(1)
              .enabled(!this.buyNowLoading)
              .onClick(() => {
                this.showBuyNowPanel();
              })
          }
          .width("100%")
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor("#FFFFFF")
          .border({ width: { top: 0.5 }, color: "#E5E5EA" })
        }
      }
      .width("100%")
      .height("100%")

      // 数量选择面板 - 覆盖层
      if (this.showBuyPanel && this.goods != null) {
        Column() {
          // 半透明遮罩（点击关闭）
          Column()
            .width("100%")
            .layoutWeight(1)
            .backgroundColor("#4D000000")
            .onClick(() => {
              this.dismissBuyPanel();
            })

          // 底部弹出面板
          Column({ space: 16 }) {
            Text("选择数量")
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor("#1A1A1A")

            Text(this.goods!.name)
              .fontSize(14)
              .fontColor("#666666")
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Row() {
              Text("单价：")
                .fontSize(14)
                .fontColor("#8E8E93")
              Text(`¥${this.goods!.price}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor("#FF3B30")
            }

            Divider().strokeWidth(0.5).color("#E5E5EA")

            Row({ space: 16 }) {
              Button("−")
                .fontSize(20)
                .fontColor(this.buyQuantity > 1 ? "#007AFF" : "#C7C7CC")
                .backgroundColor("#F0F0F5")
                .width(44)
                .height(44)
                .borderRadius(22)
                .onClick(() => {
                  if (this.buyQuantity > 1) {
                    this.buyQuantity--;
                  }
                })

              Text(this.buyQuantity.toString())
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor("#1A1A1A")
                .width(60)
                .textAlign(TextAlign.Center)

              Button("+")
                .fontSize(20)
                .fontColor(this.buyQuantity < this.goods!.num ? "#007AFF" : "#C7C7CC")
                .backgroundColor("#F0F0F5")
                .width(44)
                .height(44)
                .borderRadius(22)
                .onClick(() => {
                  if (this.buyQuantity < this.goods!.num) {
                    this.buyQuantity++;
                  }
                })
            }

            Row() {
              Text("合计：")
                .fontSize(14)
                .fontColor("#8E8E93")
              Text(`¥${this.getTotalPrice()}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor("#FF3B30")
            }

            Divider().strokeWidth(0.5).color("#E5E5EA")

            Row({ space: 12 }) {
              Button("取消")
                .fontSize(15)
                .fontColor("#007AFF")
                .backgroundColor("#FFFFFF")
                .border({ width: 1, color: "#007AFF" })
                .borderRadius(22)
                .height(44)
                .layoutWeight(1)
                .onClick(() => {
                  this.dismissBuyPanel();
                })

              Button("确认购买")
                .fontSize(15)
                .fontColor("#FFFFFF")
                .backgroundColor("#007AFF")
                .borderRadius(22)
                .height(44)
                .layoutWeight(1)
                .onClick(() => {
                  this.doBuyNowConfirm();
                })
            }
            .width("100%")
          }
          .width("100%")
          .padding(20)
          .backgroundColor("#FFFFFF")
          .borderRadius({ topLeft: 16, topRight: 16 })
        }
        .width("100%")
        .height("100%")
      }
    }
    .width("100%")
    .height("100%")
  }
}
