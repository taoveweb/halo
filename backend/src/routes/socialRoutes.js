import { Router } from 'express';

import {
  getChats,
  getNotifications,
  getChatDetail,
  markAllNotificationsRead,
  markNotificationRead,
  openChat,
  sendChatMessage,
  togglePinChat
} from '../controllers/socialController.js';
import { pushNotificationToHandle } from '../controllers/socialController.js';
import { optionalAuth, requireAuth } from '../middleware/auth.js';

const router = Router();

router.get('/notifications', optionalAuth, getNotifications);
router.post('/notifications/:id/read', requireAuth, markNotificationRead);
router.post('/notifications/read-all', requireAuth, markAllNotificationsRead);

// internal testing endpoint to push a notification to a handle (not for production)
router.post('/internal/notify', (req, res) => {
  const { handle, title, tweetId, commentId } = req.body || {};
  if (!handle) return res.status(400).json({ message: 'handle required' });
  const nt = pushNotificationToHandle(handle, { title, tweetId, commentId });
  return res.status(200).json(nt);
});

router.get('/chats', optionalAuth, getChats);
router.get('/chats/:id', requireAuth, getChatDetail);
router.post('/chats/:id/open', requireAuth, openChat);
router.post('/chats/:id/messages', requireAuth, sendChatMessage);
router.post('/chats/:id/pin', requireAuth, togglePinChat);

export default router;
