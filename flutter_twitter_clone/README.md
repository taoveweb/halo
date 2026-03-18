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
flutter run --dart-define=API_URL=http://localhost:3000/api
```

> 如果使用 Android 模拟器访问本机后端，请把 `localhost` 改为 `10.0.2.2`。


NO_PROXY=localhost,127.0.0.1,::1 flutter run -d chrome