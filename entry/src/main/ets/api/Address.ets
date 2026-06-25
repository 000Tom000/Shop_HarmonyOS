import { get, post } from './Index';
import { Address, AddressSaveRequest, DeleteAddressRequest } from '../models/Address';

interface Response {
  code: number;
  msg: string;
  data: object;
}

// 获取收货地址列表
async function getAddressList(): Promise<Address[]> {
  const res = await get("/address") as Response;
  return res.data as Address[];
}

// 获取默认收货地址
async function getDefaultAddress(): Promise<Address | null> {
  const res = await get("/address/def") as Response;
  return res.data as Address | null;
}

// 保存收货地址（新增或更新）
async function saveAddress(data: AddressSaveRequest): Promise<string> {
  const res = await post("/address/save", data) as Response;
  return res.msg;
}

// 删除收货地址
async function deleteAddress(id: number): Promise<string> {
  const req: DeleteAddressRequest = { id: id };
  const res = await post("/address/del", req) as Response;
  return res.msg;
}

export { getAddressList, getDefaultAddress, saveAddress, deleteAddress }
