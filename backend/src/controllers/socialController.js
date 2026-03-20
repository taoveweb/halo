const DEFAULT_USER_HANDLE = '@you';

// Start with empty notification seed to avoid demo/fake data in runtime state
const notificationSeed = [];

// Start with empty chat seed to avoid demo/fake data in runtime state
const chatSeed = [];

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

import { sendNotificationToHandle } from '../ws/notificationSocket.js';

export function pushNotificationToHandle(handle, notification) {
  if (!handle) return;
  const normalized = handle.trim() || DEFAULT_USER_HANDLE;
  const userState = getUserState(normalized);
  const nt = {
    id: `n${Date.now()}`,
    title: notification.title || '你有新的通知',
    minutesAgo: 0,
    read: false,
    tweetId: notification.tweetId || null,
    commentId: notification.commentId || null
  };
  userState.notifications.unshift(nt);
  // also push over websocket if client connected
  try {
    sendNotificationToHandle(normalized, nt);
  } catch (e) {
    // ignore websocket errors
  }
  return nt;
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
