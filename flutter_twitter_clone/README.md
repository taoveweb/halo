# Flutter Twitter Clone (GetX)

一个 Twitter 风格的 Flutter App，主要使用 **GetX** 做路由、依赖注入和状态管理。

## 功能
- 时间线列表
- 发布动态
- 动态详情
- 简单个人主页

## 运行
```bash
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

> 如果使用 Android 模拟器访问本机后端，请把 `localhost` 改为 `10.0.2.2`。

```bash
NO_PROXY=localhost,127.0.0.1,::1 flutter run -d chrome
```
