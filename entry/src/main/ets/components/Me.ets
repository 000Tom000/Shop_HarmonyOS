import { Header } from "./Header";
import { PromptAction, Router } from "@ohos.arkui.UIContext";
import { logout, User } from "../api/User";
import preferences from "@ohos.data.preferences";

interface MenuItem {
  icon: string,
  label: string,
  action: () => void
}

@Component
export struct Me {
  private router: Router = this.getUIContext().getRouter();
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  @StorageLink("user") user: User | null = null;

  build() {
    Column() {
      Header({ title: "个人中心" })
      Scroll() {
        Column({ space: 8 }) {
          // 头像区域
          Column({ space: 10 }) {
            Image($r("app.media.user"))
              .width(80)
              .height(80)
              .borderRadius(40)
              .border({ width: 3, color: "#FFFFFF" })
              .shadow({ radius: 8, color: '#00000020', offsetY: 2 })

            Text(this.user ? this.user.username : "还未登录，点击登录")
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor("#1A1A1A")
              .onClick(() => {
                if (!this.user) {
                  this.router.pushUrl({ url: "pages/LoginPage" })
                }
              })
          }
          .width("100%")
          .padding({ top: 30, bottom: 30 })
          .backgroundColor("#FFFFFF")

          // 菜单组1：订单相关
          Column({ space: 0 }) {
            this.MenuRow("📦", "我的订单", () => {
              this.router.pushUrl({ url: "pages/OrdersPage" })
            })
            Divider().strokeWidth(0.5).color("#F5F5F5")
            this.MenuRow("📍", "地址管理", () => {
              this.router.pushUrl({ url: "pages/AddressManagePage" })
            })
            Divider().strokeWidth(0.5).color("#F5F5F5")
            this.MenuRow("👤", "个人信息", () => {})
            Divider().strokeWidth(0.5).color("#F5F5F5")
            this.MenuRow("🔒", "修改密码", () => {})
          }
          .backgroundColor("#FFFFFF")
          .borderRadius(12)
          .width("100%")

          // 菜单组2：其他
          Column({ space: 0 }) {
            this.MenuRow("ℹ️", "关于我们", () => {})
            Divider().strokeWidth(0.5).color("#F5F5F5")
            this.MenuRow("⭐", "给我们评分", () => {})
          }
          .backgroundColor("#FFFFFF")
          .borderRadius(12)
          .width("100%")

          // 退出/登录按钮
          Button(this.user ? "退出登录" : "立即登录")
            .fontSize(16)
            .fontColor(this.user ? "#FF3B30" : "#FFFFFF")
            .backgroundColor(this.user ? "#FFFFFF" : "#007AFF")
            .borderRadius(24)
            .width("100%")
            .height(48)
            .margin({ top: 16 })
            .border({ width: this.user ? 1 : 0, color: "#FF3B30" })
            .onClick(() => {
              if (this.user) {
                logout();
                this.clearUserData();
                this.user = null;
                this.promptAction.showToast({ message: "已退出登录" })
              } else {
                this.router.pushUrl({ url: "pages/LoginPage" });
              }
            })

          // 版本号
          Text("v1.0.0")
            .fontSize(12)
            .fontColor("#C7C7CC")
            .margin({ top: 16, bottom: 20 })
            .width("100%")
            .textAlign(TextAlign.Center)
        }
        .padding({ left: 14, right: 14 })
        .width("100%")
      }
      .layoutWeight(1)
      .backgroundColor("#F5F5F5")
    }
    .width("100%")
    .height("100%")
  }

  @Builder
  MenuRow(icon: string, label: string, action: () => void) {
    Row() {
      Text(icon)
        .fontSize(20)
      Text(label)
        .fontSize(15)
        .fontColor("#1A1A1A")
        .margin({ left: 12 })
      Blank()
      Text(">")
        .fontSize(16)
        .fontColor("#C7C7CC")
    }
    .width("100%")
    .height(48)
    .padding({ left: 16, right: 16 })
    .onClick(action)
  }

  clearUserData() {
    try {
      preferences.getPreferences(getContext(), 'user').then((prefs) => {
        prefs.delete('user').then(() => {
          prefs.flush();
        });
      });
    } catch (e) {
      // ignore
    }
  }
}
