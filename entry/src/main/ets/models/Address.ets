// 收货地址数据模型
interface Address {
  id: number;
  name: string;
  tel: string;
  area: string;
  detail: string;
  is_def?: number;  // 1=默认地址, 0=非默认
}

// 保存地址的请求参数
interface AddressSaveRequest {
  name: string;
  tel: string;
  area: string;
  detail: string;
  id?: number;  // 有id是更新，无id是新增
}

// 删除地址的请求参数
interface DeleteAddressRequest {
  id: number;
}

export { Address, AddressSaveRequest, DeleteAddressRequest }
