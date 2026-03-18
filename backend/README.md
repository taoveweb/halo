# Halo Twitter Backend (Node.js + Express + MySQL)

## 快速开始
```bash
npm install
npm run dev
```

> 应用启动时会自动创建 `tweets/comments` 表，并在空库时自动初始化种子数据。
> 首次运行 `npm run dev` / `npm start` 时，如果 `.env` 不存在，后端会自动基于 `.env.example` 生成。


## API
- `GET /health`
- `GET /api/tweets`
- `GET /api/tweets/:id`
- `POST /api/tweets`
- `GET /api/tweets/:id/comments`
- `POST /api/tweets/:id/comments`

### `POST /api/tweets` body 示例
```json
{
  "content": "Hello from Flutter!",
  "author": "Your Name",
  "handle": "@your_handle"
}
```

### `POST /api/tweets/:id/comments` body 示例
```json
{
  "content": "这条动态说得好！",
  "author": "评论者",
  "handle": "@commenter"
}
```
