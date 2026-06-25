@Component
export struct Header {
  @Prop title: string = "标题";
  @Prop showBack: boolean = false;
  onBack?: () => void;

  build() {
    Row() {
      if (this.showBack) {
        Text("<")
          .fontSize(22)
          .fontColor("#FFFFFF")
          .width(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.onBack) {
              this.onBack();
            }
          })
      }
      Text(this.title)
        .fontColor("#FFFFFF")
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
      if (this.showBack) {
        // 占位保持标题居中
        Row().width(40)
      }
    }
    .width("100%")
    .height(48)
    .backgroundColor("#007AFF")
    .shadow({
      radius: 4,
      color: '#00000020',
      offsetY: 2
    })
    .alignItems(VerticalAlign.Center)
  }
}
