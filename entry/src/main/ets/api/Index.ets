import { http } from '@kit.NetworkKit';
import { JSON } from '@kit.ArkTS';
import hilog from '@ohos.hilog';

const baseUrl = 'http://10.110.37.26/api';
// const chatBaseUrl = "http://192.168.1.2:8000";
// const chatBaseUrl = "http://26.227.204.48:8000";
const chatBaseUrl = "https://office.r28886427.nyat.app:15000";

// 为了显示错误提示，需要在EntryAbility中调用setHttpAlertUIContext()，把UIContext传过来
let uiContext: UIContext;

export const setHttpAlertUIContext = (context: UIContext) => {
  uiContext = context;
};

export const get = async (path: string, data?: object) => {
  const req = http.createHttp();
  try {
    const res = await req.request(baseUrl + path, {
      expectDataType: http.HttpDataType.OBJECT,
      extraData: JSON.stringify(data),
      method: http.RequestMethod.GET,
      header: {
        "Content-Type": "application/json;charset=utf-8",
        "Authorization": AppStorage.get("token")
      }
      // connectTimeout: 2000   // 设置网络连接超时时间，方便测试网络连接失败的情况
    });
    req.destroy()
    hilog.info(0, "网络请求", JSON.stringify(res.result));
    return res.result;
  } catch (error) {
    req.destroy()
    uiContext.showAlertDialog({ message: '无法请求网络数据' }); // 显示错误提示
    throw new Error(`无法请求网络数据：${error.code} ${error.message}`);
  }
}

export const post = async (path: string, data?: object) => {
  const req = http.createHttp();
  try {
    const res = await req.request(baseUrl + path, {
      expectDataType: http.HttpDataType.OBJECT,
      extraData: JSON.stringify(data),
      method: http.RequestMethod.POST,
      header: {
        "Content-Type": "application/json;charset=utf-8",
        "Authorization": AppStorage.get("token")
      }
      // connectTimeout: 2000   // 设置网络连接超时时间，方便测试网络连接失败的情况
    });
    req.destroy()
    return res.result;
  } catch (error) {
    req.destroy()
    uiContext.showAlertDialog({ message: '无法请求网络数据' }); // 显示错误提示
    throw new Error(`无法请求网络数据：${error.code} ${error.message}`);
  }
}
export const chatPost = async (path: string, data?: object) => {
  const req = http.createHttp();
  try {
    const res = await req.request(chatBaseUrl + path, {
      expectDataType: http.HttpDataType.OBJECT,
      extraData: JSON.stringify(data),
      method: http.RequestMethod.POST,
      header: {
        "Content-Type": "application/json;charset=utf-8"
      }
      // connectTimeout: 2000   // 设置网络连接超时时间，方便测试网络连接失败的情况
    });
    req.destroy()
    return res.result;
  } catch (error) {
    req.destroy()
    uiContext.showAlertDialog({ message: '无法请求网络数据' }); // 显示错误提示
    throw new Error(`无法请求网络数据：${error.code} ${error.message}`);
  }
}
