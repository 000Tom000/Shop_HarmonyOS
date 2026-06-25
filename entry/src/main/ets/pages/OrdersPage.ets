import { Orders } from '../components/Orders'

@Entry
@Component
struct OrdersPage {
  build() {
    Column(){
      Orders()
    }
    .height("100%")
    .width("100%")
  }
}
