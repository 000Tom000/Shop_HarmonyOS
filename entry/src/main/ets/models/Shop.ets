interface Category {
  id: number,
  image: string,
  name: string,
  pid: number,
  sub: Category[]
}

interface SwiperItem{
  id: number,
  img: string
}

interface Goods{
  id: number,
  goods_category_id: number,
  name: string,
  sell_point: string,
  price: string,
  num: number,
  image: string,
  content: string
}


export { Category, SwiperItem, Goods }