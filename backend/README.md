# Halo Twitter Backend (Node.js + Express)

## 快速开始
```bash
npm install
npm run dev
```

## API
- `GET /health`
- `GET /api/tweets`
- `GET /api/tweets/:id`
- `POST /api/tweets`

### `POST /api/tweets` body 示例
```json
{
  "content": "Hello from Flutter!",
  "author": "Your Name",
  "handle": "@your_handle"
}
```
