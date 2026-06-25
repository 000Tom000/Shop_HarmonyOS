import preferences from "@ohos.data.preferences";

export interface CartItem {
  goodsId: number;
  name: string;
  image: string;
  price: string;
  count: number;
  selected: boolean;
}

const PREF_NAME = 'cart_data';
const KEY = 'cart_items';
let _items: CartItem[] = [];
let _prefs: preferences.Preferences | null = null;
let _ready = false;

// 由 Cart 组件在 aboutToAppear 中调用一次
export async function init(ctx: Context): Promise<void> {
  if (_ready) {
    return;
  }
  _prefs = await preferences.getPreferences(ctx, PREF_NAME);
  const json = await _prefs.get(KEY, '[]') as string;
  const diskItems: CartItem[] = JSON.parse(json) as CartItem[];

  // 合并：init 之前 add() 写入内存的数据合并到磁盘数据中
  if (_items.length > 0) {
    for (let i = 0; i < _items.length; i++) {
      const mem = _items[i];
      const exist = diskItems.find(d => d.goodsId === mem.goodsId);
      if (exist) {
        exist.count += mem.count;
      } else {
        diskItems.push(mem);
      }
    }
  }
  _items = diskItems;
  _ready = true;
  save();
}

function save(): void {
  if (_prefs) {
    _prefs.put(KEY, JSON.stringify(_items));
    _prefs.flush();
  }
}

// 返回当前购物车快照（深拷贝，供组件状态使用）
export function snapshot(): CartItem[] {
  const out: CartItem[] = [];
  for (let i = 0; i < _items.length; i++) {
    const src = _items[i];
    const item: CartItem = {
      goodsId: src.goodsId,
      name: src.name,
      image: src.image,
      price: src.price,
      count: src.count,
      selected: src.selected
    };
    out.push(item);
  }
  return out;
}

// 添加
export function add(item: CartItem): void {
  const exist = _items.find(i => i.goodsId === item.goodsId);
  if (exist) {
    exist.count += item.count;
  } else {
    _items.push(item);
  }
  save();
}

// 更新数量
export function updateCount(goodsId: number, count: number): void {
  const idx = _items.findIndex(i => i.goodsId === goodsId);
  if (idx !== -1) {
    if (count <= 0) {
      _items.splice(idx, 1);
    } else {
      _items[idx].count = count;
    }
    save();
  }
}

// 删除
export function remove(goodsId: number): void {
  _items = _items.filter(i => i.goodsId !== goodsId);
  save();
}

// 切换选中
export function toggleSelect(goodsId: number): void {
  const item = _items.find(i => i.goodsId === goodsId);
  if (item) {
    item.selected = !item.selected;
    save();
  }
}

// 全选/取消全选
export function toggleSelectAll(selected: boolean): void {
  for (let i = 0; i < _items.length; i++) {
    _items[i].selected = selected;
  }
  save();
}

// 删除已选中
export function removeSelected(): void {
  _items = _items.filter(i => !i.selected);
  save();
}

export function isReady(): boolean {
  return _ready;
}
