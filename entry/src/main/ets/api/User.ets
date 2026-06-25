import { get, post } from './Index';
import { PromptAction } from '@kit.ArkUI';
import hilog from '@ohos.hilog';

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

export { login, register, logout }

export { User }