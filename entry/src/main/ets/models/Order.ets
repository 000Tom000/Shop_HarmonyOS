// 订单商品（列表返回，goods_goods 仅含 id/image）
interface OrderGoods {
  id: number;
  user_order_id: number;
  goods_goods_id: number;
  count: number;
  price: string;
  create_time: string;
  update_time: string | null;
  goods_goods: OrderGoodsInfo;
}

// 订单详情中的商品（goods_goods 额外含 name）
interface OrderGoodsInfo {
  id: number;
  name?: string;
  image: string;
}

// 订单
interface Order {
  id: number;
  user_user_id: number;
  price: string;
  address_name: string;
  address_tel: string;
  address_area: string;
  address_detail: string;
  note: string;
  is_pay: number;     // 0=未支付, 1=已支付
  is_cancel: number;   // 0=正常, 1=已取消
  create_time: string;
  update_time: string | null;
  user_order_goods: OrderGoods[];
}

// 创建订单 - 单个商品
interface CreateOrderGoods {
  id: string;      // 商品ID（API中为字符串）
  count: number;
  selected: boolean;
}

// 创建订单请求
interface CreateOrderRequest {
  address: number;
  goods: CreateOrderGoods[];
  note: string;
}

// 取消订单请求
interface CancelOrderRequest {
  id: number;
}

// 订单ID参数（用于查询详情）
interface OrderIdRequest {
  id: number;
}

export { Order, OrderGoods, OrderGoodsInfo, CreateOrderRequest, CreateOrderGoods, CancelOrderRequest, OrderIdRequest }
