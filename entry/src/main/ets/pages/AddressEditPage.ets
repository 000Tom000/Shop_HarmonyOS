import { Header } from '../components/Header';
import { PromptAction, Router } from '@ohos.arkui.UIContext';
import { saveAddress } from '../api/Address';
import { Address, AddressSaveRequest } from '../models/Address';

@Entry
@Component
struct AddressEditPage {
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  private router: Router = this.getUIContext().getRouter();

  // 页面标题和模式
  @State pageTitle: string = "添加收货地址";
  @State isEdit: boolean = false;

  // 表单字段
  @State name: string = "";
  @State tel: string = "";
  @State area: string = "";
  @State detail: string = "";
  private editId: number = 0;

  aboutToAppear(): void {
    // 获取路由传参，如果有address数据则是编辑模式
    const params = this.router.getParams() as Record<string, Object>;
    if (params) {
      const addr = params['address'] as Address;
      if (addr) {
        this.isEdit = true;
        this.pageTitle = "编辑收货地址";
        this.editId = addr.id;
        this.name = addr.name;
        this.tel = addr.tel;
        this.area = addr.area;
        this.detail = addr.detail;
      }
    }
  }

  build() {
    Column() {
      Header({
        title: this.pageTitle,
        showBack: true,
        onBack: () => { this.router.back() }
      })

      Scroll() {
        Column({ space: 16 }) {
          // 收货人姓名
          Column({ space: 6 }) {
            Text("收货人")
              .fontSize(14)
              .fontColor("#666666")
              .width("100%")
            TextInput({
              text: $$this.name,
              placeholder: "请输入收货人姓名"
            })
              .type(InputType.Normal)
              .height(44)
              .backgroundColor("#F5F5F5")
              .borderRadius(10)
              .padding({ left: 12, right: 12 })
          }

          // 手机号码
          Column({ space: 6 }) {
            Text("手机号码")
              .fontSize(14)
              .fontColor("#666666")
              .width("100%")
            TextInput({
              text: $$this.tel,
              placeholder: "请输入手机号码"
            })
              .type(InputType.PhoneNumber)
              .maxLength(11)
              .height(44)
              .backgroundColor("#F5F5F5")
              .borderRadius(10)
              .padding({ left: 12, right: 12 })
          }

          // 所在地区
          Column({ space: 6 }) {
            Text("所在地区")
              .fontSize(14)
              .fontColor("#666666")
              .width("100%")
            TextInput({
              text: $$this.area,
              placeholder: "省/市/区，如：广东省广州市天河区"
            })
              .type(InputType.Normal)
              .height(44)
              .backgroundColor("#F5F5F5")
              .borderRadius(10)
              .padding({ left: 12, right: 12 })
          }

          // 详细地址
          Column({ space: 6 }) {
            Text("详细地址")
              .fontSize(14)
              .fontColor("#666666")
              .width("100%")
            TextInput({
              text: $$this.detail,
              placeholder: "街道、门牌号等详细地址"
            })
              .type(InputType.Normal)
              .height(44)
              .backgroundColor("#F5F5F5")
              .borderRadius(10)
              .padding({ left: 12, right: 12 })
          }

          // 保存按钮
          Button(this.isEdit ? "保存修改" : "保存地址")
            .fontSize(16)
            .fontColor("#FFFFFF")
            .backgroundColor("#007AFF")
            .borderRadius(22)
            .width("100%")
            .height(44)
            .margin({ top: 8 })
            .onClick(() => {
              // 表单校验
              if (!this.name.trim()) {
                this.promptAction.showToast({ message: "请输入收货人姓名" })
                return
              }
              if (!this.tel.trim()) {
                this.promptAction.showToast({ message: "请输入手机号码" })
                return
              }
              if (this.tel.trim().length !== 11) {
                this.promptAction.showToast({ message: "请输入正确的11位手机号码" })
                return
              }
              if (!this.area.trim()) {
                this.promptAction.showToast({ message: "请输入所在地区" })
                return
              }
              if (!this.detail.trim()) {
                this.promptAction.showToast({ message: "请输入详细地址" })
                return
              }

              // 构建请求数据
              const reqData: AddressSaveRequest = {
                name: this.name.trim(),
                tel: this.tel.trim(),
                area: this.area.trim(),
                detail: this.detail.trim()
              }
              if (this.isEdit) {
                reqData.id = this.editId;
              }

              saveAddress(reqData).then((msg) => {
                this.promptAction.showToast({ message: msg || (this.isEdit ? "修改成功" : "添加成功") })
                // 延迟返回，让用户看到提示
                setTimeout(() => {
                  this.router.back();
                }, 500);
              })
            })
        }
        .padding(20)
      }
      .layoutWeight(1)
      .backgroundColor("#F5F5F5")
    }
    .width("100%")
    .height("100%")
  }
}
