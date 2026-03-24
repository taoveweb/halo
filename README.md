# Halo Twitter-like Fullstack Demo

该仓库包含两部分：

- `flutter_twitter_clone/`：Flutter 客户端（GetX）
- `backend/`：Node.js + Express + MySQL API
- `admin-web/`：Vue3 + Element Plus + Pinia 后台管理系统
- `wechat_miniprogram/`：微信小程序客户端（含 5 栏 Tab Bar）

## 1) 启动后端
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

## 2) 启动后台管理系统
```bash
cd admin-web
npm install
npm run dev
```

## 3) 启动 Flutter
```bash
cd flutter_twitter_clone
flutter pub get
```

### 环境化 API 配置（开发 / 测试 / 生产）

客户端支持以下 `dart-define`：

- `APP_ENV=dev|test|prod`：选择环境（默认 `dev`）
- `API_URL_DEV`：开发环境 API（默认 `http://localhost:3000/api`）
- `API_URL_TEST`：测试环境 API（默认 `https://test-api.example.com/api`）
- `API_URL_PROD`：生产环境 API（默认 `https://api.example.com/api`）
- `API_URL`：强制覆盖，优先级最高（不区分环境）

示例：

```bash
# 本地开发
flutter run --dart-define=APP_ENV=dev

# 测试环境
flutter run --dart-define=APP_ENV=test --dart-define=API_URL_TEST=https://test.your-domain.com/api

# 生产环境
flutter run --dart-define=APP_ENV=prod --dart-define=API_URL_PROD=https://api.your-domain.com/api

# 临时强制覆盖（优先级最高）
flutter run --dart-define=APP_ENV=prod --dart-define=API_URL=https://hotfix-api.your-domain.com/api
```

## 4) 启动微信小程序
```bash
# 使用微信开发者工具打开 wechat_miniprogram 目录
```

## 结构
```text
.
├── backend
│   └── src
├── flutter_twitter_clone
│   └── lib/app
└── wechat_miniprogram
    └── pages
```
