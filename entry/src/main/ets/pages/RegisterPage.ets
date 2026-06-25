import { Header } from '../components/Header';
import { PromptAction, Router } from '@ohos.arkui.UIContext';
import { register } from '../api/User';

@Entry
@Component
struct RegisterPage {
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  private router: Router = this.getUIContext().getRouter();
  @State email: string = "";
  @State username: string = "";
  @State password: string = "";
  @State passwordConfirm: string = "";
  @State passwordMismatch: boolean = false;

  build() {
    Column() {
      Header({ title: "注册", showBack: true, onBack: () => { this.router.back() } })
      Scroll() {
        Column({ space: 24 }) {
          Text("创建账号")
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor("#1A1A1A")
            .margin({ top: 20 })

          Column({ space: 16 }) {
            // 邮箱
            Column({ space: 6 }) {
              Text("邮箱（选填）")
                .fontSize(14)
                .fontColor("#666666")
                .width("100%")
              TextInput({
                text: $$this.email,
                placeholder: "请输入您的邮箱"
              })
                .type(InputType.Email)
                .height(44)
                .backgroundColor("#F5F5F5")
                .borderRadius(10)
                .padding({ left: 12, right: 12 })
            }

            // 用户名
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

            // 密码
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
                .onChange(() => {
                  this.checkPasswordMatch();
                })
            }

            // 确认密码
            Column({ space: 6 }) {
              Text("确认密码")
                .fontSize(14)
                .fontColor("#666666")
                .width("100%")
              TextInput({
                text: $$this.passwordConfirm,
                placeholder: "请确认您的密码"
              })
                .type(InputType.Password)
                .height(44)
                .backgroundColor("#F5F5F5")
                .borderRadius(10)
                .padding({ left: 12, right: 12 })
                .onChange(() => {
                  this.checkPasswordMatch();
                })
              if (this.passwordMismatch && this.passwordConfirm.length > 0) {
                Text("两次密码输入不一致")
                  .fontSize(12)
                  .fontColor("#FF3B30")
              }
            }

            Button("注册")
              .fontSize(16)
              .fontColor("#FFFFFF")
              .backgroundColor("#007AFF")
              .borderRadius(22)
              .width("100%")
              .height(44)
              .margin({ top: 8 })
              .onClick(() => {
                if (!(this.username && this.password && this.passwordConfirm)) {
                  this.promptAction.showToast({ message: "请补全信息再注册" })
                } else if (this.password !== this.passwordConfirm) {
                  this.promptAction.showToast({ message: "两次密码输入不一致" })
                } else {
                  register(this.username, this.password, this.email).then(res => {
                    this.promptAction.showToast({ message: res })
                    if (res == "注册成功") {
                      setTimeout(() => { this.router.back(); }, 666);
                    }
                  })
                }
              })

            Row({ space: 4 }) {
              Text("已有账号？")
                .fontSize(14)
                .fontColor("#8E8E93")
              Text("返回登录")
                .fontSize(14)
                .fontColor("#007AFF")
                .fontWeight(FontWeight.Medium)
                .onClick(() => { this.router.back(); })
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

  checkPasswordMatch() {
    if (this.passwordConfirm.length > 0) {
      this.passwordMismatch = this.password !== this.passwordConfirm;
    } else {
      this.passwordMismatch = false;
    }
  }
}
