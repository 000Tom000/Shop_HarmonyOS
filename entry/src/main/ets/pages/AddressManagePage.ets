import { Header } from '../components/Header';
import { PromptAction, Router } from '@ohos.arkui.UIContext';
import { getAddressList, deleteAddress } from '../api/Address';
import { Address } from '../models/Address';

@Entry
@Component
struct AddressManagePage {
  private router: Router = this.getUIContext().getRouter();
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  @State addresses: Address[] = [];
  @State loading: boolean = true;

  aboutToAppear(): void {
    this.loadAddresses();
  }

  // 页面每次显示时刷新列表（从编辑页返回时触发）
  onPageShow(): void {
    this.loadAddresses();
  }

  loadAddresses() {
    this.loading = true;
    getAddressList().then((list) => {
      this.addresses = list || [];
      this.loading = false;
    });
  }

  build() {
    Column() {
      Header({
        title: "收货地址管理",
        showBack: true,
        onBack: () => { this.router.back() }
      })

      if (this.loading) {
        // 加载中状态
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
      } else if (this.addresses.length === 0) {
        // 空状态
        Column({ space: 15 }) {
          Text("📍")
            .fontSize(48)
          Text("暂无收货地址")
            .fontSize(16)
            .fontColor("#8E8E93")
          Text("点击下方按钮添加新地址")
            .fontSize(13)
            .fontColor("#C7C7CC")
        }
        .width("100%")
        .layoutWeight(1)
        .backgroundColor("#F5F5F5")
        .justifyContent(FlexAlign.Center)
      } else {
        // 地址列表
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.addresses, (item: Address, index: number) => {
              Column({ space: 6 }) {
                // 第一行：姓名 + 电话
                Row() {
                  Text(item.name)
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                    .fontColor("#1A1A1A")
                  Blank()
                  Text(item.tel)
                    .fontSize(14)
                    .fontColor("#666666")
                }
                .width("100%")

                // 第二行：地区 + 详细地址
                Text(item.area + " " + item.detail)
                  .fontSize(14)
                  .fontColor("#666666")
                  .width("100%")
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                // 第三行：默认标签 + 操作按钮
                Row() {
                  if (item.is_def === 1) {
                    Text("默认")
                      .fontSize(11)
                      .fontColor("#007AFF")
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .border({ width: 0.5, color: "#007AFF" })
                      .borderRadius(4)
                  }
                  Blank()
                  Text("编辑")
                    .fontSize(13)
                    .fontColor("#007AFF")
                    .margin({ right: 16 })
                    .onClick(() => {
                      this.router.pushUrl({
                        url: "pages/AddressEditPage",
                        params: { address: item }
                      })
                    })
                  Text("删除")
                    .fontSize(13)
                    .fontColor("#FF3B30")
                    .onClick(() => {
                      this.confirmDelete(item, index);
                    })
                }
                .width("100%")
              }
              .padding(14)
              .backgroundColor("#FFFFFF")
              .borderRadius(12)
              .onClick(() => {
                // 点击整个卡片进入编辑
                this.router.pushUrl({
                  url: "pages/AddressEditPage",
                  params: { address: item }
                })
              })
            }, (item: Address) => item.id.toString())
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

      // 底部添加按钮（有列表时显示）
      if (!this.loading) {
        Button("+ 添加新地址")
          .fontSize(16)
          .fontColor("#FFFFFF")
          .backgroundColor("#007AFF")
          .borderRadius(24)
          .width("90%")
          .height(44)
          .margin({ bottom: 16 })
          .onClick(() => {
            this.router.pushUrl({ url: "pages/AddressEditPage" })
          })
      }
    }
    .width("100%")
    .height("100%")
  }

  // 确认删除弹窗
  confirmDelete(item: Address, index: number) {
    AlertDialog.show({
      title: "确认删除",
      message: `确定要删除"${item.name}"的收货地址吗？`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: "取消",
        action: () => {}
      },
      secondaryButton: {
        value: "删除",
        fontColor: "#FF3B30",
        action: () => {
          deleteAddress(item.id).then((msg) => {
            this.addresses.splice(index, 1);
            this.promptAction.showToast({ message: msg || "删除成功" })
          })
        }
      }
    })
  }
}
