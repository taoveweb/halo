import { Router } from 'express';

import { login, logout, me, register, updateProfile, uploadAvatar } from '../controllers/authController.js';
import {
  getCommentsByTweetId,
  getTweetById,
  getTweets,
  postComment,
  postTweet,
  updateTweetInteraction
} from '../controllers/tweetController.js';
import { requireAuth } from '../middleware/auth.js';

const router = Router();

router.post('/auth/register', register);
router.post('/auth/login', login);
router.get('/auth/me', requireAuth, me);
router.post('/auth/avatar', requireAuth, uploadAvatar);
router.patch('/auth/profile', requireAuth, updateProfile);
router.post('/auth/logout', requireAuth, logout);

router.get('/tweets', getTweets);
router.get('/tweets/:id', getTweetById);
router.post('/tweets', requireAuth, postTweet);
router.get('/tweets/:id/comments', getCommentsByTweetId);
router.post('/tweets/:id/comments', requireAuth, postComment);

export default router;
