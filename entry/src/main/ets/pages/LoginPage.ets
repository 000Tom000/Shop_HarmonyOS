import { login, User } from '../api/User';
import { Header } from '../components/Header';
import { PromptAction, Router } from '@ohos.arkui.UIContext';
import preferences from '@ohos.data.preferences';
import { JSON } from '@kit.ArkTS';

@Entry
@Component
struct LoginPage {
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  private router: Router = this.getUIContext().getRouter();

  @StorageLink("user") user: User | null = null;
  @State username: string = "";
  @State password: string = "";

  build() {
    Column() {
      Header({ title: "登录", showBack: true, onBack: () => { this.router.back() } })
      Scroll() {
        Column({ space: 24 }) {
          // Logo
          Image($r("app.media.SHOP"))
            .width(64)
            .height(64)
            .borderRadius(16)
            .margin({ top: 20 })

          Text("欢迎回来")
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor("#1A1A1A")

          // 登录表单
          Column({ space: 16 }) {
            Column({ space: 6 }) {
              Text("用户名")
                .fontSize(14)
                .fontColor("#666666")
                .width("100%")
              TextInput({
                text: $$this.username,
                placeholder: "请输入您的用户名"
              })
                .type(InputType.Normal)
                .height(44)
                .backgroundColor("#F5F5F5")
                .borderRadius(10)
                .padding({ left: 12, right: 12 })
            }
            Column({ space: 6 }) {
              Text("密码")
                .fontSize(14)
                .fontColor("#666666")
                .width("100%")
              TextInput({
                text: $$this.password,
                placeholder: "请输入您的密码"
              })
                .type(InputType.Password)
                .height(44)
                .backgroundColor("#F5F5F5")
                .borderRadius(10)
                .padding({ left: 12, right: 12 })
            }

            Button("登录")
              .fontSize(16)
              .fontColor("#FFFFFF")
              .backgroundColor("#007AFF")
              .borderRadius(22)
              .width("100%")
              .height(44)
              .margin({ top: 8 })
              .onClick(() => {
                if (!this.username || !this.password) {
                  this.promptAction.showToast({ message: "请填写完整信息" })
                  return
                }
                login(this.username, this.password).then(res => {
                  if (res) {
                    this.user = res;
                    AppStorage.setOrCreate("token", res.session_id);
                    this.saveUserData(res);
                    this.promptAction.showToast({ message: "登录成功！" })
                    setTimeout(() => { this.router.back(); }, 666);
                  } else {
                    this.promptAction.showToast({ message: "用户名或密码错误" })
                  }
                })
              })

            Row({ space: 4 }) {
              Text("还没账号？")
                .fontSize(14)
                .fontColor("#8E8E93")
              Text("立即注册")
                .fontSize(14)
                .fontColor("#007AFF")
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  this.router.pushUrl({ url: "pages/RegisterPage" })
                })
            }
            .justifyContent(FlexAlign.Center)
            .width("100%")
          }
          .padding(20)
          .backgroundColor("#FFFFFF")
          .borderRadius(16)
        }
        .padding({ left: 20, right: 20 })
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .backgroundColor("#F5F5F5")
    }
    .width("100%")
    .height("100%")
  }

  saveUserData(user: User) {
    try {
      preferences.getPreferences(getContext(), 'user').then((prefs) => {
        prefs.put("user", JSON.stringify(user)).then(() => {
          prefs.flush();
        });
      });
    } catch (e) {
      // ignore
    }
  }
}
