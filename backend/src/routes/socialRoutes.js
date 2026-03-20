import { Router } from 'express';

import {
  getChats,
  getNotifications,
  markAllNotificationsRead,
  markNotificationRead,
  openChat,
  togglePinChat
} from '../controllers/socialController.js';
import { optionalAuth, requireAuth } from '../middleware/auth.js';

const router = Router();

router.get('/notifications', optionalAuth, getNotifications);
router.post('/notifications/:id/read', requireAuth, markNotificationRead);
router.post('/notifications/read-all', requireAuth, markAllNotificationsRead);

router.get('/chats', optionalAuth, getChats);
router.post('/chats/:id/open', requireAuth, openChat);
router.post('/chats/:id/pin', requireAuth, togglePinChat);

export default router;
