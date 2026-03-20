import { Router } from 'express';

import {
  adminLogin,
  adminLogout,
  adminMe,
  deleteAdminComment,
  deleteAdminTopic,
  deleteAdminTweet,
  getAdminAuditLogs,
  getAdminComments,
  getAdminDashboard,
  getAdminTopics,
  getAdminTweetComments,
  getAdminTweets,
  getAdminUsers
} from '../controllers/adminController.js';
import { requireAdminAuth } from '../middleware/adminAuth.js';

const router = Router();

router.post('/admin/auth/login', adminLogin);
router.get('/admin/auth/me', requireAdminAuth, adminMe);
router.post('/admin/auth/logout', requireAdminAuth, adminLogout);

router.get('/admin/dashboard', requireAdminAuth, getAdminDashboard);
router.get('/admin/tweets', requireAdminAuth, getAdminTweets);
router.get('/admin/tweets/:id/comments', requireAdminAuth, getAdminTweetComments);
router.delete('/admin/tweets/:id', requireAdminAuth, deleteAdminTweet);

router.get('/admin/users', requireAdminAuth, getAdminUsers);
router.get('/admin/comments', requireAdminAuth, getAdminComments);
router.delete('/admin/comments/:id', requireAdminAuth, deleteAdminComment);
router.get('/admin/topics', requireAdminAuth, getAdminTopics);
router.delete('/admin/topics/:id', requireAdminAuth, deleteAdminTopic);

router.get('/admin/audit-logs', requireAdminAuth, getAdminAuditLogs);

export default router;
