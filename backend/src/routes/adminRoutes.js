import { Router } from 'express';

import {
  adminLogin,
  adminLogout,
  adminMe,
  deleteAdminComment,
  deleteAdminTweet,
  getAdminAuditLogs,
  getAdminComments,
  getAdminDashboard,
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
router.delete('/admin/tweets/:id', requireAdminAuth, deleteAdminTweet);

router.get('/admin/users', requireAdminAuth, getAdminUsers);
router.get('/admin/comments', requireAdminAuth, getAdminComments);
router.delete('/admin/comments/:id', requireAdminAuth, deleteAdminComment);

router.get('/admin/audit-logs', requireAdminAuth, getAdminAuditLogs);

export default router;
