const DEFAULT_USER_HANDLE = '@you';

const notificationSeed = [
  { id: 'n1', title: 'Halo Team 赞了你的动态', minutesAgo: 2, read: false },
  { id: 'n2', title: 'Jane Doe 转发了你的动态', minutesAgo: 8, read: false },
  { id: 'n3', title: '你关注的人 @dev_tom 发布了新动态', minutesAgo: 22, read: false },
  { id: 'n4', title: 'Flutter 中文社区 回复了你', minutesAgo: 60, read: true },
  { id: 'n5', title: '你的动态获得了 10 次新点赞', minutesAgo: 120, read: true },
  { id: 'n6', title: '@product_amy 关注了你', minutesAgo: 180, read: true }
];

const chatSeed = [
  { id: 'c1', name: 'Jane Doe', message: '首页交互我已经提交 PR 啦。', time: '刚刚', unreadCount: 2, pinned: false },
  { id: 'c2', name: 'Halo Team', message: '今晚 8 点上线新版本，记得回归测试。', time: '12:20', unreadCount: 0, pinned: false },
  { id: 'c3', name: 'dev_tom', message: '可以把评论接口也接一下吗？', time: '昨天', unreadCount: 1, pinned: false },
  { id: 'c4', name: 'product_amy', message: '下周加上推荐流页面如何？', time: '周二', unreadCount: 0, pinned: false },
  { id: 'c5', name: 'design_lily', message: '我更新了深色主题规范。', time: '周一', unreadCount: 0, pinned: false }
];

const state = new Map();

function resolveHandle(req) {
  return req.authUser?.handle || req.query.viewerHandle?.trim() || DEFAULT_USER_HANDLE;
}

function getUserState(handle) {
  if (!state.has(handle)) {
    state.set(handle, {
      notifications: notificationSeed.map((item) => ({ ...item })),
      chats: chatSeed.map((item) => ({ ...item }))
    });
  }
  return state.get(handle);
}

export async function getNotifications(req, res) {
  const userState = getUserState(resolveHandle(req));
  res.status(200).json(userState.notifications);
}

export async function markNotificationRead(req, res) {
  const userState = getUserState(resolveHandle(req));
  const target = userState.notifications.find((item) => item.id === req.params.id);
  if (!target) {
    return res.status(404).json({ message: 'Notification not found' });
  }
  target.read = true;
  return res.status(200).json(target);
}

export async function markAllNotificationsRead(req, res) {
  const userState = getUserState(resolveHandle(req));
  userState.notifications.forEach((item) => {
    item.read = true;
  });
  return res.status(200).json(userState.notifications);
}

function sortChats(chats) {
  chats.sort((a, b) => {
    if (a.pinned === b.pinned) return 0;
    return a.pinned ? -1 : 1;
  });
}

export async function getChats(req, res) {
  const userState = getUserState(resolveHandle(req));
  sortChats(userState.chats);
  res.status(200).json(userState.chats);
}

export async function openChat(req, res) {
  const userState = getUserState(resolveHandle(req));
  const target = userState.chats.find((item) => item.id === req.params.id);
  if (!target) {
    return res.status(404).json({ message: 'Chat not found' });
  }
  target.unreadCount = 0;
  target.time = '刚刚';
  return res.status(200).json(target);
}

export async function togglePinChat(req, res) {
  const userState = getUserState(resolveHandle(req));
  const target = userState.chats.find((item) => item.id === req.params.id);
  if (!target) {
    return res.status(404).json({ message: 'Chat not found' });
  }
  target.pinned = !target.pinned;
  sortChats(userState.chats);
  return res.status(200).json(target);
}
