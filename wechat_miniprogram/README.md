# Halo 微信小程序客户端

当前版本已完成与 Flutter 客户端一致的 5 栏底部导航（Tab Bar）：

1. 首页
2. 搜索
3. 社区
4. 通知
5. 消息

> 当前实现为纯文本/Emoji 自定义底部栏，不依赖二进制图标文件，便于在不支持二进制附件的代码托管流程中提交。

## 本地运行

1. 打开微信开发者工具。
2. 导入本目录 `wechat_miniprogram/`。
3. 使用测试号 `appid`（`touristappid`）预览。

如果需要真机调试，请在 `project.config.json` 中替换为你自己的小程序 `appid`。
