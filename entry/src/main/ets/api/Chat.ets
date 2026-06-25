import { chatPost } from './Index'

interface ChatRequest{
  message: string
}
interface ChatResponse{
  answer: string
}
async function chat(message: string){
  const res = await chatPost("/chat", { message } as ChatRequest) as ChatResponse;
  return res.answer;
}

export { chat }