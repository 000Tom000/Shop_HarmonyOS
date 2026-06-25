import { get, post } from './Index';
import { Order, CreateOrderRequest, CancelOrderRequest, OrderIdRequest } from '../models/Order';

interface Response {
  code: number;
  msg: string;
  data: object;
}

// 获取订单列表
async function getOrderList(): Promise<Order[]> {
  const res = await get("/order/list") as Response;
  return res.data as Order[];
}

// 获取订单详情
async function getOrderDetail(id: number): Promise<Order> {
  const req: OrderIdRequest = { id: id };
  const res = await get("/order/show", req) as Response;
  return res.data as Order;
}

// 创建订单
async function createOrder(data: CreateOrderRequest): Promise<string> {
  const res = await post("/order/create", data) as Response;
  return res.msg;
}

// 取消订单
async function cancelOrder(id: number): Promise<string> {
  const req: CancelOrderRequest = { id: id };
  const res = await post("/order/cancel", req) as Response;
  return res.msg;
}

export { getOrderList, getOrderDetail, createOrder, cancelOrder }
