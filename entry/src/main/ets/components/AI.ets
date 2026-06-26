import { chat } from "../api/Chat"
import { Header } from "./Header"
import { PromptAction } from "@ohos.arkui.UIContext"

interface Message {
  role: number,
  content: string
}

@Component
export struct AI {
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  private scroller: Scroller = new Scroller();
  @State messages: Message[] = [{ role: 0, content: "..." }]
  @State inputText: string = ""
  @State canAsk: boolean = false;

  aboutToAppear(): void {
    this.showAnswer("您好，我是AI助手，有什么可以帮您？");
  }

  showAnswer(answer: string) {
    const lastIndex = this.messages.length - 1;
    const ans: string[] = answer.split("");
    this.messages[lastIndex].content = "";
    const timer = setInterval(() => {
      this.messages[lastIndex].content += ans.shift();
      this.messages = [...this.messages];
      setTimeout(() => {
        this.scroller.scrollTo({
          xOffset: 0,
          yOffset: 99999,
          animation: true
        })
      }, 50);
      if (ans.length == 0) {
        this.canAsk = true;
        clearInterval(timer);
      }
    }, 66);
  }

  build() {
    Column() {
      Header({ title: "智能小助手" })
      // 聊天区域
      Scroll(this.scroller) {
        Column() {
          ForEach(this.messages, (msg: Message) => {
            this.MessageBubble(msg)
          })
        }
        .width("100%")
        .padding({ top: 12, bottom: 12, left: 10, right: 10 })
        .justifyContent(FlexAlign.Start)
      }
      .layoutWeight(1)
      .backgroundColor("#F5F5F5")

      // 底部输入栏
      Row() {
        TextInput({ placeholder: "输入消息...", text: $$this.inputText })
          .layoutWeight(1)
          .height(40)
          .backgroundColor("#FFFFFF")
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
        Button(this.canAsk ? "发送" : "⏳")
          .fontSize(14)
          .width(60)
          .height(36)
          .borderRadius(18)
          .backgroundColor(this.canAsk ? "#007AFF" : "#C7C7CC")
          .margin({ left: 8 })
          .onClick(() => {
            if (this.canAsk) this.sendMessage();
            else this.promptAction.showToast({ message: "请等待回答完毕" })
          })
      }
      .width("100%")
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .backgroundColor("#FFFFFF")
      .border({ width: { top: 0.5 }, color: "#E5E5EA" })
    }
    .width("100%")
    .height("100%")
  }

  @Builder
  MessageBubble(msg: Message) {
    Row() {
      if (msg.role == 0) {
        // AI 消息
        Image($r("app.media.AI_avator"))
          .width(36)
          .height(36)
          .borderRadius(18)
          .margin({ right: 8 })
        Column() {
          Text(msg.content)
            .padding(12)
            .backgroundColor("#FFFFFF")
            .borderRadius({ topLeft: 4, topRight: 12, bottomLeft: 12, bottomRight: 12 })
            .fontSize(15)
            .fontColor("#1A1A1A")
            .constraintSize({ maxWidth: "70%" })
            .border({ width: { left: 3 }, color: "#007AFF" })
        }
      } else {
        // 用户消息
        Blank().layoutWeight(1)
        Column() {
          Text(msg.content)
            .padding(12)
            .backgroundColor("#4A90E2")
            .fontColor(Color.White)
            .borderRadius({ topLeft: 12, topRight: 4, bottomLeft: 12, bottomRight: 12 })
            .fontSize(15)
            .constraintSize({ maxWidth: "70%" })
        }
        Image($r("app.media.user"))
          .width(36)
          .height(36)
          .borderRadius(18)
          .margin({ left: 8 })
      }
    }
    .width("100%")
    .margin({ top: 6, bottom: 6 })
    .alignItems(VerticalAlign.Top)
  }

  async sendMessage() {
    if (!this.inputText.trim()) return
    this.canAsk = false;
    this.messages.push({ role: 1, content: this.inputText })
    const question = this.inputText;
    this.inputText = "";
    setTimeout(() => {
      this.messages.push({ role: 0, content: "..." })
    }, 333);
    const res = await chat(question);
    this.showAnswer(res);
  }
}
// 你好，你是谁？
