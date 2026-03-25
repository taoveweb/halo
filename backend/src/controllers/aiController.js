const OPENAI_API_URL = 'https://api.openai.com/v1/responses';
const DEFAULT_MODEL = process.env.OPENAI_MODEL || 'gpt-4.1-mini';
<<<<<<< HEAD
import { HttpsProxyAgent } from 'https-proxy-agent'
const proxyAgent = new HttpsProxyAgent('http://172.20.10.1:8899')
=======

>>>>>>> temp-save
export async function chatWithAi(req, res, next) {
  try {
    const prompt = `${req.body?.prompt ?? ''}`.trim();
    if (!prompt) {
      return res.status(400).json({ message: 'prompt 不能为空' });
    }

    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      return res.status(503).json({
        message: 'OPENAI_API_KEY 未配置，暂时无法使用 AI 对话',
      });
    }

    const userLabel = req.user?.handle || req.user?.email || 'anonymous';
    const response = await fetch(OPENAI_API_URL, {
      method: 'POST',
<<<<<<< HEAD
       // ✅ 关键在这里
=======
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
>>>>>>> temp-save
      body: JSON.stringify({
        model: DEFAULT_MODEL,
        temperature: 0.7,
        max_output_tokens: 600,
        input: [
          {
            role: 'system',
            content: [
              {
                type: 'input_text',
                text: '你是 Halo App 里的 AI 助手，回答风格简洁友好，优先使用中文。',
              },
            ],
          },
          {
            role: 'user',
            content: [{ type: 'input_text', text: prompt }],
          },
        ],
        metadata: {
          source: 'halo-mobile',
          user: userLabel,
        },
      }),
<<<<<<< HEAD
      agent: proxyAgent, 
=======
>>>>>>> temp-save
    });

    if (!response.ok) {
      const detail = await response.text();
      return res.status(502).json({
        message: 'AI 服务调用失败',
        detail,
      });
    }

    const data = await response.json();
    const text = `${data?.output_text ?? ''}`.trim();

    if (!text) {
      return res.status(502).json({ message: 'AI 返回内容为空' });
    }

    return res.status(200).json({
      reply: text,
      model: data?.model ?? DEFAULT_MODEL,
      responseId: data?.id ?? null,
    });
  } catch (error) {
<<<<<<< HEAD
    console.log(error,'error')
=======
>>>>>>> temp-save
    return next(error);
  }
}
