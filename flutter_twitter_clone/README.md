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

## 鸿蒙（HarmonyOS / OpenHarmony）支持

本项目业务代码使用标准 Flutter API（未使用仅 Android / iOS 可用的原生插件），可迁移到鸿蒙 Flutter 发行版运行。

### 推荐做法

1. 安装鸿蒙 Flutter 工具链（例如 `flutter-ohos` 发行版）。
2. 在项目中创建鸿蒙平台工程（通常会新增 `ohos/` 目录）。
3. 执行依赖安装并启动：

```bash
flutter pub get
flutter run -d ohos
```

### 注意事项

- 若你接入了新的三方插件，请先确认该插件提供 `ohos` 实现。
- 网络 API 配置方式与 Android / iOS 保持一致，继续使用下方 `dart-define` 即可。

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

# 生产环境构建
flutter build web --release --dart-define=APP_ENV=prod

# 测试环境构建  
flutter build web --release --dart-define=APP_ENV=test

# 开发环境构建（默认）
flutter build web --release --dart-define=APP_ENV=dev

```

