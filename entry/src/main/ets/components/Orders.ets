import { User } from "../api/User";
import { Header } from "./Header"
import { Router } from "@kit.ArkUI";
import { getOrderList, cancelOrder } from "../api/Order";
import { Order, OrderGoods } from "../models/Order";
import { PromptAction } from "@ohos.arkui.UIContext";

interface OrderTab {
  id: number,
  label: string
}

@Component
export struct Orders {
  private router: Router = this.getUIContext().getRouter();
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  @StorageLink("user") user: User | null = null;
  @State currentTab: number = 0;
  @State orders: Order[] = [];
  @State loading: boolean = true;
  private tabs: OrderTab[] = [
    { id: 0, label: "全部" },
    { id: 1, label: "待付款" },
    { id: 2, label: "已付款" },
    { id: 3, label: "已取消" }
  ];

  aboutToAppear(): void {
    if (!this.user) {
      setTimeout(() => {
        this.router.pushUrl({ url: "pages/LoginPage" })
      }, 100);
      return;
    }
    this.loadOrders();
  }

  // 每次 Tab 切回时刷新
  onPageShow(): void {
    if (this.user) {
      this.loadOrders();
    }
  }

  loadOrders() {
    this.loading = true;
    getOrderList().then((list) => {
      this.orders = list || [];
      this.loading = false;
    });
  }

  // 根据当前Tab筛选订单
  getFilteredOrders(): Order[] {
    if (this.currentTab === 0) {
      return this.orders;  // 全部
    } else if (this.currentTab === 1) {
      // 待付款: 未支付且未取消
      return this.orders.filter((o) => o.is_pay === 0 && o.is_cancel === 0);
    } else if (this.currentTab === 2) {
      // 已付款: 已支付且未取消
      return this.orders.filter((o) => o.is_pay === 1 && o.is_cancel === 0);
    } else if (this.currentTab === 3) {
      // 已取消
      return this.orders.filter((o) => o.is_cancel === 1);
    }
    return this.orders;
  }

  // 获取状态文本
  getStatusText(order: Order): string {
    if (order.is_cancel === 1) {
      return "已取消";
    } else if (order.is_pay === 1) {
      return "已付款";
    } else {
      return "待付款";
    }
  }

  // 获取状态颜色
  getStatusColor(order: Order): string {
    if (order.is_cancel === 1) {
      return "#8E8E93";
    } else if (order.is_pay === 1) {
      return "#34C759";
    } else {
      return "#FF9500";
    }
  }

  // 获取第一张商品图片
  getFirstImage(order: Order): string {
    if (order.user_order_goods && order.user_order_goods.length > 0) {
      return order.user_order_goods[0].goods_goods.image;
    }
    return "";
  }

  // 获取商品总数
  getTotalCount(order: Order): number {
    let total = 0;
    if (order.user_order_goods) {
      order.user_order_goods.forEach((g) => { total += g.count; });
    }
    return total;
  }

  build() {
    Column() {
      Header({ title: "我的订单" })

      // 订单状态Tab
      Row() {
        ForEach(this.tabs, (tab: OrderTab, index: number) => {
          Text(tab.label)
            .fontSize(13)
            .fontColor(this.currentTab == index ? "#007AFF" : "#666666")
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .padding({ top: 10, bottom: 10 })
            .border({
              width: { bottom: this.currentTab == index ? 2 : 0 },
              color: "#007AFF"
            })
            .onClick(() => { this.currentTab = index })
        })
      }
      .width("100%")
      .backgroundColor("#FFFFFF")
      .border({ width: { bottom: 0.5 }, color: "#E5E5EA" })

      if (this.loading) {
        // 加载中
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
      } else if (this.getFilteredOrders().length === 0) {
        // 空状态
        Scroll() {
          Column({ space: 15 }) {
            Text("📦")
              .fontSize(48)
            Text("暂无订单")
              .fontSize(16)
              .fontColor("#8E8E93")
            Text("快去挑选心仪的商品吧")
              .fontSize(13)
              .fontColor("#C7C7CC")
          }
          .width("100%")
          .height("100%")
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .backgroundColor("#F5F5F5")
      } else {
        // 订单列表
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.getFilteredOrders(), (order: Order) => {
              Column({ space: 0 }) {
                // 订单头部：订单号 + 状态
                Row() {
                  Text(`订单号：${order.id}`)
                    .fontSize(13)
                    .fontColor("#8E8E93")
                  Blank()
                  Text(this.getStatusText(order))
                    .fontSize(13)
                    .fontColor(this.getStatusColor(order))
                    .fontWeight(FontWeight.Medium)
                }
                .width("100%")
                .padding({ left: 14, right: 14, top: 10, bottom: 8 })

                // 商品缩略预览
                Row() {
                  // 商品预览图（最多显示3张）
                  Row({ space: 6 }) {
                    ForEach(order.user_order_goods.slice(0, 3), (goods: OrderGoods) => {
                      Image(goods.goods_goods.image)
                        .width(64)
                        .height(64)
                        .borderRadius(6)
                        .objectFit(ImageFit.Cover)
                    })
                  }

                  Blank()

                  // 商品数量和总价
                  Column({ space: 4 }) {
                    Text(`共${this.getTotalCount(order)}件`)
                      .fontSize(12)
                      .fontColor("#8E8E93")
                    Text(`¥${order.price}`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor("#1A1A1A")
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width("100%")
                .padding({ left: 14, right: 14, top: 6, bottom: 10 })

                // 底部操作栏
                Row() {
                  Blank()
                  if (order.is_pay === 0 && order.is_cancel === 0) {
                    // 待付款：取消订单按钮
                    Button("取消订单")
                      .fontSize(12)
                      .fontColor("#8E8E93")
                      .backgroundColor("#F5F5F5")
                      .borderRadius(14)
                      .height(30)
                      .padding({ left: 12, right: 12 })
                      .onClick(() => {
                        this.confirmCancel(order);
                      })
                  }
                }
                .width("100%")
                .padding({ left: 14, right: 14, bottom: 12 })
              }
              .backgroundColor("#FFFFFF")
              .borderRadius(12)
              .onClick(() => {
                this.router.pushUrl({
                  url: "pages/OrderDetailPage",
                  params: { orderId: order.id }
                })
              })
            }, (order: Order) => order.id.toString())
          }
          .padding(10)
          .constraintSize({
            minHeight: "100%"
          })
          .justifyContent(FlexAlign.Start)
        }
        .layoutWeight(1)
        .backgroundColor("#F5F5F5")
      }
    }
    .width("100%")
    .height("100%")
  }

  // 确认取消弹窗
  confirmCancel(order: Order) {
    AlertDialog.show({
      title: "取消订单",
      message: `确定要取消订单 ${order.id} 吗？`,
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
          cancelOrder(order.id).then((msg) => {
            this.promptAction.showToast({ message: msg || "已取消" })
            this.loadOrders();
          })
        }
      }
    })
  }
}
