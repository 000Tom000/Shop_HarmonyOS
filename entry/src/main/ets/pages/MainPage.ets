import { Me } from '../components/Me';
import { News } from '../components/News';
import { Shop } from '../components/Shop';
import { Router } from '@kit.ArkUI';
import { AI } from '../components/AI';
import { Cart } from '../components/Cart';

interface Tab {
  id: number,
  tab: string,
  icon: Resource,
  icon_selected?: Resource
}

@Entry
@Component
struct Home {
  private router: Router = this.getUIContext().getRouter();
  private tabs: Tab[] = [{
    id: 0,
    tab: "商品",
    icon: $r("app.media.shopping"),
  }, {
    id: 1,
    tab: "新闻",
    icon: $r("app.media.news"),
  }, {
    id: 2,
    tab: "AI助手",
    icon: $r("app.media.AI"),
  }, {
    id: 3,
    tab: "购物车",
    icon: $r("app.media.shopping"),
  }, {
    id: 4,
    tab: "我的",
    icon: $r("app.media.me"),
  }];
  private tabsController: TabsController = new TabsController();

  @State currentTab: number = 0;

  // @Watch("tabChange")
  // @State ct: number = -1;
  //
  // tabChange(newIndex: number, oldIndex: number) {
  //   this.tabsController.changeIndex(newIndex);
  // }

  @Builder
  tabBarBuilder(item: Tab) {
    Column({ space: 2 }) {
      Image(item.icon)
        .height(22)
        .width(22)
        .fillColor(this.currentTab == item.id ? '#007AFF' : '#8E8E93')
      Text(item.tab)
        .fontSize(11)
        .fontColor(this.currentTab == item.id ? '#007AFF' : '#8E8E93')
    }
    .padding({ top: 6, bottom: 4 })
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        ForEach(this.tabs, (tab: Tab) => {
          TabContent() {
            if (tab.id == 0) {
              Shop();
            } else if (tab.id == 1) {
              News();
            } else if (tab.id == 2) {
              AI();
            } else if (tab.id == 3) {
              Cart();
            } else if (tab.id == 4) {
              Me();
            }
          }.tabBar(this.tabBarBuilder(tab))
        })
      }
      .barHeight(54)
      .onChange((index) => {
        this.currentTab = index;
      })
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#F5F5F5")
  }
}
