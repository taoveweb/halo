# Halo Twitter Backend (Node.js + Express + MySQL)

## 快速开始
```bash
npm install
cp .env.example .env
npm run dev
```

> 应用启动时会自动创建 `tweets/comments` 表，并在空库时自动初始化种子数据。

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
