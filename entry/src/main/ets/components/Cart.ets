import { Header } from "./Header";
import { CartItem, init, snapshot, remove, updateCount, toggleSelect, toggleSelectAll, removeSelected } from "../models/Cart";
import { Router } from "@kit.ArkUI";
import { PromptAction } from "@ohos.arkui.UIContext";
import { User } from "../api/User";
import { getDefaultAddress } from "../api/Address";
import { createOrder } from "../api/Order";
import { CreateOrderGoods, CreateOrderRequest } from "../models/Order";

@Component
export struct Cart {
  private router: Router = this.getUIContext().getRouter();
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  @StorageLink("user") user: User | null = null;
  @Watch("onCartVersionChange") @StorageProp("cartVersion") cartVersion: number = 0;
  @State items: CartItem[] = [];
  @State loading: boolean = true;
  @State checkouting: boolean = false;

  async aboutToAppear(): Promise<void> {
    await init(getContext());
    this.refresh();
  }

  onCartVersionChange(): void {
    this.refresh();
  }

  refresh() {
    // snapshot() 返回全新数组 + 全新对象，保证 ArkUI 检测到引用变化
    this.items = snapshot();
    this.loading = false;
  }

  getAllSelected(): boolean {
    if (this.items.length === 0) {
      return false;
    }
    for (let i = 0; i < this.items.length; i++) {
      if (!this.items[i].selected) {
        return false;
      }
    }
    return true;
  }

  getTotal(): string {
    let t = 0;
    for (let i = 0; i < this.items.length; i++) {
      const s = this.items[i];
      if (s.selected) {
        t += parseFloat(s.price) * s.count;
      }
    }
    return t.toFixed(2);
  }

  getSelCount(): number {
    let c = 0;
    for (let i = 0; i < this.items.length; i++) {
      if (this.items[i].selected) {
        c += this.items[i].count;
      }
    }
    return c;
  }
  // 你好，你是谁？

  doToggleAll() {
    toggleSelectAll(!this.getAllSelected());
    this.refresh();
  }

  doToggle(goodsId: number) {
    toggleSelect(goodsId);
    this.refresh();
  }

  doChange(goodsId: number, delta: number) {
    const found = this.items.find(s => s.goodsId === goodsId);
    if (!found) {
      return;
    }
    const nc = found.count + delta;
    if (nc <= 0) {
      AlertDialog.show({
        title: "删除商品",
        message: `确定要从购物车删除"${found.name}"吗？`,
        autoCancel: true,
        alignment: DialogAlignment.Center,
        secondaryButton: {
          value: "删除",
          fontColor: "#FF3B30",
          action: () => {
            remove(goodsId);
            this.refresh();
          }
        },
        primaryButton: {
          value: "取消",
          action: () => {}
        }
      });
    } else {
      updateCount(goodsId, nc);
      this.refresh();
    }
  }

  doDelete(item: CartItem) {
    AlertDialog.show({
      title: "删除商品",
      message: `确定要从购物车删除"${item.name}"吗？`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      secondaryButton: {
        value: "删除",
        fontColor: "#FF3B30",
        action: () => {
          remove(item.goodsId);
          this.refresh();
        }
      },
      primaryButton: {
        value: "取消",
        action: () => {}
      }
    });
  }

  async doCheckout() {
    if (!this.user) {
      this.promptAction.showToast({ message: "请先登录" });
      setTimeout(() => {
        this.router.pushUrl({ url: "pages/LoginPage" });
      }, 500);
      return;
    }

    const selected = this.items.filter(s => s.selected);
    if (selected.length === 0) {
      this.promptAction.showToast({ message: "请选择要购买的商品" });
      return;
    }

    this.checkouting = true;
    const address = await getDefaultAddress();
    if (!address) {
      this.checkouting = false;
      AlertDialog.show({
        title: "提示",
        message: "请先添加收货地址",
        autoCancel: true,
        alignment: DialogAlignment.Center,
        primaryButton: { value: "取消", action: () => {} },
        secondaryButton: {
          value: "去添加",
          action: () => { this.router.pushUrl({ url: "pages/AddressManagePage" }); }
        }
      });
      return;
    }

    const sc = this.getSelCount();
    const st = this.getTotal();
    AlertDialog.show({
      title: "确认下单",
      message: `收货地址：${address.area} ${address.detail}\n收货人：${address.name} ${address.tel}\n共${sc}件商品，合计 ¥${st}`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: "取消",
        action: () => { this.checkouting = false; }
      },
      secondaryButton: {
        value: "确认下单",
        action: async () => {
          try {
            const g: CreateOrderGoods[] = [];
            for (let i = 0; i < selected.length; i++) {
              const s = selected[i];
              const cg: CreateOrderGoods = {
                id: s.goodsId.toString(),
                count: s.count,
                selected: true
              };
              g.push(cg);
            }
            const req: CreateOrderRequest = {
              address: address.id,
              goods: g,
              note: ""
            };
            const msg = await createOrder(req);
            this.promptAction.showToast({ message: msg || "下单成功" });
            removeSelected();
            this.refresh();
            AppStorage.setOrCreate("cartVersion", (AppStorage.get("cartVersion") as number || 0) + 1);
          } catch (e) {
            this.promptAction.showToast({ message: "下单失败，请重试" });
          } finally {
            this.checkouting = false;
          }
        }
      }
    });
  }

  build() {
    Column() {
      Header({ title: "购物车" })

      if (this.loading) {
        Column() {
          LoadingProgress().width(36).height(36).color("#007AFF").margin({ bottom: 12 })
          Text("加载中...").fontSize(14).fontColor("#8E8E93")
        }
        .width("100%").layoutWeight(1).justifyContent(FlexAlign.Center).backgroundColor("#F5F5F5")
      } else if (this.items.length === 0) {
        Scroll() {
          Column({ space: 15 }) {
            Text("🛒").fontSize(48)
            Text("购物车是空的").fontSize(16).fontColor("#8E8E93")
            Text("快去挑选心仪的商品吧").fontSize(13).fontColor("#C7C7CC")
          }
          .width("100%").height("100%").justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1).backgroundColor("#F5F5F5")
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.items, (item: CartItem, index: number) => {
              Column({ space: 0 }) {
                Row() {
                  Text(item.selected ? "✅" : "⬜")
                    .fontSize(20)
                    .onClick(() => { this.doToggle(item.goodsId) })

                  Image(item.image)
                    .width(72).height(72).borderRadius(8).objectFit(ImageFit.Cover).margin({ left: 10 })

                  Column({ space: 6 }) {
                    Text(item.name)
                      .fontSize(14).fontColor("#1A1A1A").maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Row() {
                      Text(`¥${item.price}`)
                        .fontSize(16).fontWeight(FontWeight.Bold).fontColor("#FF3B30")
                      Blank()
                      Row({ space: 0 }) {
                        Text("−")
                          .fontSize(16).fontColor("#007AFF")
                          .width(28).height(28).textAlign(TextAlign.Center)
                          .borderRadius(14).backgroundColor("#F0F0F5")
                          .onClick(() => { this.doChange(item.goodsId, -1) })
                        Text(item.count.toString())
                          .fontSize(14).fontColor("#1A1A1A")
                          .width(36).textAlign(TextAlign.Center)
                        Text("+")
                          .fontSize(16).fontColor("#007AFF")
                          .width(28).height(28).textAlign(TextAlign.Center)
                          .borderRadius(14).backgroundColor("#F0F0F5")
                          .onClick(() => { this.doChange(item.goodsId, 1) })
                      }
                    }
                    .width("100%")
                  }
                  .layoutWeight(1).margin({ left: 10 }).alignItems(HorizontalAlign.Start)
                }
                .width("100%").padding(12).alignItems(VerticalAlign.Top)

                Row() {
                  Blank()
                  Button("删除")
                    .fontSize(11).fontColor("#8E8E93").backgroundColor("#F5F5F5")
                    .borderRadius(12).height(28).padding({ left: 10, right: 10 })
                    .onClick(() => { this.doDelete(item) })
                }
                .width("100%").padding({ left: 12, right: 12, bottom: 10 })
              }
              .backgroundColor("#FFFFFF").borderRadius(12)
            }, (item: CartItem) => item.goodsId.toString())
          }
          .padding({ left: 10, right: 10, top: 10, bottom: 10 })
          .constraintSize({ minHeight: "100%" })
        }
        .layoutWeight(1).backgroundColor("#F5F5F5")
      }

      if (this.items.length > 0 && !this.loading) {
        Row() {
          Row({ space: 6 }) {
            Text(this.getAllSelected() ? "✅" : "⬜").fontSize(18)
            Text("全选").fontSize(13).fontColor("#666666")
          }
          .onClick(() => { this.doToggleAll() })

          Blank()

          Column({ space: 2 }) {
            Text(`合计：¥${this.getTotal()}`)
              .fontSize(16).fontWeight(FontWeight.Bold).fontColor("#FF3B30")
            Text(`共${this.getSelCount()}件`).fontSize(11).fontColor("#8E8E93")
          }
          .alignItems(HorizontalAlign.End).margin({ right: 12 })

          Button(`结算(${this.getSelCount()})`)
            .fontSize(14).fontColor("#FFFFFF")
            .backgroundColor(this.getSelCount() > 0 && !this.checkouting ? "#FF3B30" : "#C7C7CC")
            .borderRadius(20).height(40).padding({ left: 18, right: 18 })
            .onClick(() => { this.doCheckout() })
        }
        .width("100%").padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor("#FFFFFF").border({ width: { top: 0.5 }, color: "#E5E5EA" })
      }
    }
    .width("100%").height("100%")
  }
}
