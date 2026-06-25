import { Category, Goods, SwiperItem } from '../models/Shop';
import { get } from './Index'

interface Response {
  code: number;
  msg: string;
  data: object;
}

async function getCategories() {
  const res = await get("/category") as Response;
  return res.data as Category[];
}

async function getSwiperList() {
  const res = await get("/imglist") as Response;
  return res.data as SwiperItem[];
}

async function getGoodsList(categoryId: number) {
  const res = await get(`/goodslist?category_id=${categoryId}`) as Response;
  return res.data as Goods[];
}

async function getGoodsInfo(goodsId: number) {
  const res = await get(`/goodsinfo?id=${goodsId}`) as Response;
  return res.data as Goods;
}

function getImageUrl(url: string) {
  return "http://10.110.37.26/static/uploads/" + url;
}

export { getCategories, getSwiperList, getGoodsList, getGoodsInfo, getImageUrl }