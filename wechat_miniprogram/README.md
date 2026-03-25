# Halo 微信小程序客户端

本次已将微信小程序从“5 个空壳 Tab”升级为与 Flutter 端对齐的完整业务链路（基于同一套后端 API）：

## 功能对齐清单

- 认证：登录 / 注册 / 获取当前用户 / 退出登录。
- 首页：推荐流、关注流、点赞、转发、跳转动态详情。
- 发布：发布新动态。
- 动态详情：浏览记录、评论列表、发表评论。
- 搜索：关键词搜索动态与话题，支持关注/取消关注话题。
- 社区：加入/退出社区。
- 通知：通知列表、单条已读、全部已读。
- 消息：会话列表、置顶会话、会话详情、发送消息。
- 个人资料：编辑昵称/账号/邮箱、修改密码、退出登录。

## 页面结构

- Tab 页面：
  - `pages/home/index`
  - `pages/search/index`
  - `pages/communities/index`
  - `pages/notifications/index`
  - `pages/messages/index`
- 非 Tab 页面：
  - `pages/auth/index`
  - `pages/compose/index`
  - `pages/tweet-detail/index`
  - `pages/message-detail/index`
  - `pages/profile/index`

## 本地运行

1. 启动后端服务（默认 `http://127.0.0.1:3000`）。
2. 打开微信开发者工具。
3. 导入本目录 `wechat_miniprogram/`。
4. 使用测试号 `appid`（`touristappid`）预览。

> 如需真机调试，请替换 `project.config.json` 中的 `appid`。

## API 地址

默认配置在 `utils/config.js`，可按 dev/test/prod 修改后端地址。
