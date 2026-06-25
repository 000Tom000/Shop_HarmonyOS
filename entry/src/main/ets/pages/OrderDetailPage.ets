import { Header } from '../components/Header';
import { PromptAction, Router } from '@ohos.arkui.UIContext';
import { getOrderDetail, cancelOrder } from '../api/Order';
import { Order, OrderGoods } from '../models/Order';

@Entry
@Component
struct OrderDetailPage {
  private router: Router = this.getUIContext().getRouter();
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  @State order: Order | null = null;
  @State loading: boolean = true;
  private orderId: number = 0;

  aboutToAppear(): void {
    const params = this.router.getParams() as Record<string, Object>;
    if (params && params['orderId']) {
      this.orderId = params['orderId'] as number;
      this.loadDetail();
    }
  }

  loadDetail() {
    this.loading = true;
    getOrderDetail(this.orderId).then((detail) => {
      this.order = detail;
      this.loading = false;
    });
  }

  getStatusText(): string {
    if (!this.order) return "";
    if (this.order.is_cancel === 1) {
      return "已取消";
    } else if (this.order.is_pay === 1) {
      return "已付款";
    } else {
      return "待付款";
    }
  }

  getStatusColor(): string {
    if (!this.order) return "#8E8E93";
    if (this.order.is_cancel === 1) {
      return "#8E8E93";
    } else if (this.order.is_pay === 1) {
      return "#34C759";
    } else {
      return "#FF9500";
    }
  }

  getTotalCount(): number {
    if (!this.order || !this.order.user_order_goods) return 0;
    let total = 0;
    this.order.user_order_goods.forEach((g) => { total += g.count; });
    return total;
  }

  build() {
    Column() {
      Header({
        title: "订单详情",
        showBack: true,
        onBack: () => { this.router.back() }
      })

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color("#007AFF")
            .margin({ bottom: 12 })
          Text("加载中...")
            .fontSize(14)
            .fontColor("#8E8E93")
        }
        .width("100%")
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor("#F5F5F5")
      } else if (!this.order) {
        Column() {
          Text("订单不存在")
            .fontSize(16)
            .fontColor("#8E8E93")
        }
        .width("100%")
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor("#F5F5F5")
      } else {
        Scroll() {
          Column({ space: 10 }) {
            // 状态横幅
            Row() {
              Text(this.getStatusText())
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor("#FFFFFF")
              Blank()
              Text(`订单号：${this.order.id}`)
                .fontSize(13)
                .fontColor("#FFFFFF90")
            }
            .width("100%")
            .padding(16)
            .backgroundColor(this.getStatusColor())
            .borderRadius(12)

            // 收货地址
            Column({ space: 4 }) {
              Row() {
                Text("📍")
                  .fontSize(16)
                Text("收货地址")
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor("#1A1A1A")
                  .margin({ left: 6 })
              }
              .width("100%")

              Text(`${this.order.address_name}  ${this.order.address_tel}`)
                .fontSize(14)
                .fontColor("#1A1A1A")
                .width("100%")

              Text(`${this.order.address_area} ${this.order.address_detail}`)
                .fontSize(13)
                .fontColor("#666666")
                .width("100%")
            }
            .padding(14)
            .backgroundColor("#FFFFFF")
            .borderRadius(12)

            // 商品列表
            Column({ space: 0 }) {
              ForEach(this.order.user_order_goods, (goods: OrderGoods, index: number) => {
                Column() {
                  Row({ space: 10 }) {
                    Image(goods.goods_goods.image)
                      .width(72)
                      .height(72)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)

                    Column({ space: 4 }) {
                      Text(goods.goods_goods.name || `商品 #${goods.goods_goods_id}`)
                        .fontSize(14)
                        .fontColor("#1A1A1A")
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width("100%")

                      Text(`¥${goods.price}`)
                        .fontSize(13)
                        .fontColor("#8E8E93")
                        .width("100%")

                      Row() {
                        Text(`x${goods.count}`)
                          .fontSize(13)
                          .fontColor("#8E8E93")
                        Blank()
                        Text(`¥${(parseFloat(goods.price) * goods.count).toFixed(2)}`)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor("#1A1A1A")
                      }
                      .width("100%")
                    }
                    .layoutWeight(1)
                  }
                  .width("100%")

                  if (index < this.order!.user_order_goods.length - 1) {
                    Divider()
                      .strokeWidth(0.5)
                      .color("#F0F0F0")
                      .margin({ top: 10, bottom: 10 })
                  }
                }
                .width("100%")
              })
            }
            .padding(14)
            .backgroundColor("#FFFFFF")
            .borderRadius(12)

            // 订单信息
            Column({ space: 8 }) {
              this.InfoRow("商品总额", `¥${this.order.price}`)
              this.InfoRow("商品数量", `${this.getTotalCount()}件`)
              if (this.order.note) {
                this.InfoRow("备注", this.order.note)
              }
              this.InfoRow("创建时间", this.order.create_time)
            }
            .padding(14)
            .backgroundColor("#FFFFFF")
            .borderRadius(12)

            // 金额汇总
            Row() {
              Text("实付金额")
                .fontSize(15)
                .fontColor("#1A1A1A")
              Blank()
              Text(`¥${this.order.price}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor("#FF3B30")
            }
            .width("100%")
            .padding(14)
            .backgroundColor("#FFFFFF")
            .borderRadius(12)

            // 取消按钮（仅待付款状态显示）
            if (this.order.is_pay === 0 && this.order.is_cancel === 0) {
              Button("取消订单")
                .fontSize(16)
                .fontColor("#FF3B30")
                .backgroundColor("#FFFFFF")
                .borderRadius(24)
                .border({ width: 1, color: "#FF3B30" })
                .width("100%")
                .height(44)
                .margin({ top: 4 })
                .onClick(() => {
                  this.confirmCancel();
                })
            }

            // 底部留白
            Blank().height(20)
          }
          .padding(10)
        }
        .layoutWeight(1)
        .backgroundColor("#F5F5F5")
      }
    }
    .width("100%")
    .height("100%")
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor("#8E8E93")
      Blank()
      Text(value)
        .fontSize(13)
        .fontColor("#1A1A1A")
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: "60%" })
    }
    .width("100%")
  }

  confirmCancel() {
    AlertDialog.show({
      title: "取消订单",
      message: `确定要取消订单 ${this.orderId} 吗？`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: "再想想",
        action: () => {}
      },
      secondaryButton: {
        value: "确认取消",
        fontColor: "#FF3B30",
        action: () => {
          cancelOrder(this.orderId).then((msg) => {
            this.promptAction.showToast({ message: msg || "已取消" })
            this.loadDetail();
          })
        }
      }
    })
  }
}
