# Halo Twitter-like Fullstack Demo

该仓库包含两部分：

- `flutter_twitter_clone/`：Flutter 客户端（GetX）
- `backend/`：Node.js + Express + MySQL API
- `admin-web/`：Vue3 + Element Plus + Pinia 后台管理系统

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
flutter run --dart-define=API_URL=http://localhost:3000/api
```

## 结构
```text
.
├── backend
│   └── src
└── flutter_twitter_clone
    └── lib/app
```
