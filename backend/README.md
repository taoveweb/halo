# Halo Twitter Backend (Node.js + Express + MySQL)

## 快速开始
```bash
npm install
npm run dev
```

> 应用启动时会自动创建 `users/auth_tokens/tweets/comments` 表，并在空库时自动初始化种子数据。
> 首次运行 `npm run dev` / `npm start` 时，如果 `.env` 不存在，后端会自动基于 `.env.example` 生成。

## 演示账号
- 邮箱：`halo@example.com`
- 密码：`123456`

## API
- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`（需要 Bearer Token）
- `POST /api/auth/logout`（需要 Bearer Token）
- `GET /api/tweets`
- `GET /api/tweets/:id`
- `POST /api/tweets`（需要 Bearer Token）
- `GET /api/tweets/:id/comments`
- `POST /api/tweets/:id/comments`（需要 Bearer Token）

### `POST /api/auth/register` body 示例
```json
{
  "name": "Halo User",
  "handle": "@halo_user",
  "email": "halo@example.com",
  "password": "123456"
}
```

### `POST /api/auth/login` body 示例
```json
{
  "email": "halo@example.com",
  "password": "123456"
}
```


## Admin API
- `POST /api/admin/auth/login`
- `GET /api/admin/auth/me`（需要 Bearer Token）
- `POST /api/admin/auth/logout`（需要 Bearer Token）
- `GET /api/admin/dashboard`（需要 Bearer Token）
- `GET /api/admin/tweets`（需要 Bearer Token）
- `DELETE /api/admin/tweets/:id`（需要 Bearer Token）
- `GET /api/admin/users`（需要 Bearer Token）
- `GET /api/admin/comments`（需要 Bearer Token）
- `DELETE /api/admin/comments/:id`（需要 Bearer Token）
- `GET /api/admin/audit-logs`（需要 Bearer Token）

### 后台增强点（本次新增）
- 管理员登录失败限流：15 分钟窗口最多 5 次，超过后临时锁定。
- 仪表盘新增当日增量数据（新增用户、推文、评论）。
- 新增用户管理、评论管理、审计日志 API，便于做后台治理与追踪。

### 默认后台账号
- 用户名：`admin`
- 密码：`admin123456`

> 可通过 `.env` 中的 `ADMIN_USERNAME`、`ADMIN_PASSWORD` 覆盖默认账号。
