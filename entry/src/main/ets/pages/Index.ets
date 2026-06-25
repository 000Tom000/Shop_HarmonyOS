import { PromptAction, Router } from '@ohos.arkui.UIContext';
import preferences from '@ohos.data.preferences';
import { User } from '../api/User';
import { JSON } from '@kit.ArkTS';

@Entry
@Component
struct Index {
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  private router: Router = this.getUIContext().getRouter();

  aboutToAppear(): void {
    this.loadUserData();
    // setTimeout(() => {
    //   this.promptAction.showToast({ message: "点击进入商城" })
    // }, 1111);
  }

  loadUserData() {
    try {
      preferences.getPreferences(getContext(), 'user').then((prefs) => {
        prefs.get("user", "").then((saved) => {
          if (saved) {
            const user: User = JSON.parse(saved.toString()) as User;
            AppStorage.setOrCreate("user", user);
            AppStorage.setOrCreate("token", user.session_id);
          }
        });
      });
    } catch (e) {
      // 首次启动无数据，忽略
    }
  }

  build() {
    Column() {
      Column({ space: 18 }) {
        // Logo 区域
        Image($r("app.media.SHOP"))
          .width(80)
          .height(80)
          .borderRadius(20)
          .shadow({ radius: 12, color: '#00000020', offsetY: 4 })

        Text("欢迎来到线上商城")
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor("#1A1A1A")

        Text("品质生活，尽在掌握")
          .fontSize(15)
          .fontColor("#8E8E93")

        Blank().height(20)

        Button("进入商城")
          .fontSize(17)
          .fontColor("#FFFFFF")
          .backgroundColor("#007AFF")
          .borderRadius(24)
          .width("66%")
          .height(48)
          .shadow({ radius: 8, color: '#007AFF40', offsetY: 4 })
          .onClick(() => {
            this.router.replaceUrl({ url: "pages/MainPage" })
          })
      }
      .width("100%")
      .padding({ top: 40, bottom: 40 })
      .borderRadius(0)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width("100%")
    .height("100%")
    .backgroundColor("#F5F5F5")
  }
}
