import { Router } from 'express';

import {
  adminLogin,
  adminLogout,
  adminMe,
  deleteAdminTweet,
  getAdminDashboard,
  getAdminTweets
} from '../controllers/adminController.js';
import { requireAdminAuth } from '../middleware/adminAuth.js';

const router = Router();

router.post('/admin/auth/login', adminLogin);
router.get('/admin/auth/me', requireAdminAuth, adminMe);
router.post('/admin/auth/logout', requireAdminAuth, adminLogout);

router.get('/admin/dashboard', requireAdminAuth, getAdminDashboard);
router.get('/admin/tweets', requireAdminAuth, getAdminTweets);
router.delete('/admin/tweets/:id', requireAdminAuth, deleteAdminTweet);

export default router;
