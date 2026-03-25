const DEFAULT_USER_HANDLE = '@you';

const notificationSeed = [];

const chatSeed = [
  {
    id: 'c_huaxianzi',
    name: '花仙子🌼',
    handle: '@huaxianzi999',
    avatar: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=200&q=80',
    message: '在吗，我关注了您，请喝茶☕~',
    time: 'Now',
    unreadCount: 1,
    pinned: false,
    joinedAt: '2017-11-01'
  }
];

const chatThreadSeed = {
  c_huaxianzi: {
    id: 'c_huaxianzi',
    user: {
      name: '花仙子🌼',
      handle: '@huaxianzi999',
      avatar: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=200&q=80',
      joinedAt: '2017-11-01'
    },
    createdDate: '2023-08-12',
    messages: [
      {
        id: 'm1',
        direction: 'inbound',
        text: '在吗，我关注了您，请喝茶☕~',
        time: '18:48',
        createdAt: Date.parse('2023-08-12T18:48:00.000Z')
      }
    ]
  }
};

const state = new Map();

function resolveHandle(req) {
  return req.authUser?.handle || req.query.viewerHandle?.trim() || DEFAULT_USER_HANDLE;
}

function deepClone(value) {
  return JSON.parse(JSON.stringify(value));
}

function getUserState(handle) {
  if (!state.has(handle)) {
    state.set(handle, {
      notifications: notificationSeed.map((item) => ({ ...item })),
      chats: chatSeed.map((item) => ({ ...item })),
      chatThreads: deepClone(chatThreadSeed)
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
  try {
    sendNotificationToHandle(normalized, nt);
  } catch (e) {}
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

export async function getChatDetail(req, res) {
  const userState = getUserState(resolveHandle(req));
  const chat = userState.chats.find((item) => item.id === req.params.id);
  const detail = userState.chatThreads[req.params.id];
  if (!chat || !detail) {
    return res.status(404).json({ message: 'Chat not found' });
  }
  return res.status(200).json({
    ...detail,
    unreadCount: chat.unreadCount,
    pinned: chat.pinned
  });
}

export async function openChat(req, res) {
  const userState = getUserState(resolveHandle(req));
  const target = userState.chats.find((item) => item.id === req.params.id);
  if (!target) {
    return res.status(404).json({ message: 'Chat not found' });
  }
  target.unreadCount = 0;
  return res.status(200).json(target);
}

export async function sendChatMessage(req, res) {
  const userState = getUserState(resolveHandle(req));
  const target = userState.chats.find((item) => item.id === req.params.id);
  const detail = userState.chatThreads[req.params.id];
  const text = req.body?.text?.toString().trim();
  if (!target || !detail) {
    return res.status(404).json({ message: 'Chat not found' });
  }
  if (!text) {
    return res.status(400).json({ message: 'text is required' });
  }

  const now = new Date();
  const hh = now.getHours().toString().padStart(2, '0');
  const mm = now.getMinutes().toString().padStart(2, '0');
  const msg = {
    id: `m${Date.now()}`,
    direction: 'outbound',
    text,
    time: `${hh}:${mm}`,
    createdAt: now.getTime()
  };

  detail.messages.push(msg);
  target.message = text;
  target.time = 'Now';
  target.unreadCount = 0;

  return res.status(201).json(msg);
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
