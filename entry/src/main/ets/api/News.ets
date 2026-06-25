import { get } from './Index';
import { New, NewsInfo } from '../models/News';

interface Response{
  status: number,
  message: object
}
async function getNewsList() {
  const res = await get(`/news/list`) as Response;
  return res.message as New[];
}

async function getNewsInfo(newsId: number){
  const res = await get(`/news/show?id=${newsId}`) as Response;
  return res.message[0] as NewsInfo;
}

export { getNewsList, getNewsInfo }