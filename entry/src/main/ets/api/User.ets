import { get, post } from './Index';
import { PromptAction } from '@kit.ArkUI';
import hilog from '@ohos.hilog';
import { http } from '@kit.NetworkKit';

const baseUrl = 'http://10.110.37.26/api';

interface Response {
  code: number;
  msg: string;
  data: object;
}

interface LoginRequest {
  username: string,
  password: string
}

interface RegisterRequest {
  username: string,
  password: string,
  email: string| null| undefined
}

interface User {
  id: number,
  username: string,
  session_id: string
}

async function login(username: string, password: string) {
  const ps: LoginRequest = {
    username, password
  }
  const res = await post("/login", ps) as Response;
  // hilog.info(0, "登录login", JSON.stringify(ps));
  const user = res.data as User | null;
  // hilog.info(0, "登录login", JSON.stringify(user));
  // if(user) AppStorage.setOrCreate("user", user);
  return user? user: false;
}

async function register(username: string, password: string, email?: string) {
  const ps: RegisterRequest = {
    username, password, email
  };
  const res = await post("/register", ps) as Response;
  return res.msg;
}

async function logout(){
  await get("/logout");
}

// 静默验证token是否有效，不会弹出错误提示
async function checkLoginStatus(): Promise<boolean> {
  const token: string | null = AppStorage.get("token") as string | null;
  if (!token) {
    return false;
  }
  const req: http.HttpRequest = http.createHttp();
  try {
    const res = await req.request(baseUrl + "/user/info", {
      expectDataType: http.HttpDataType.OBJECT,
      method: http.RequestMethod.GET,
      header: {
        "Content-Type": "application/json;charset=utf-8",
        "Authorization": token
      }
    });
    req.destroy();
    const result: Response = res.result as Response;
    // 如果有返回用户数据说明token有效
    if (result.data && (result.data as User).id) {
      return true;
    }
    return false;
  } catch (e) {
    req.destroy();
    // 网络错误时不判定为过期，保持当前登录状态
    return true;
  }
}

export { login, register, logout, checkLoginStatus }

export { User }