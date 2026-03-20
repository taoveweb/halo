import { Router } from 'express';

import { login, logout, me, register, updateProfile, uploadAvatar } from '../controllers/authController.js';
import {
  getCommentsByTweetId,
  getTweetById,
  getTweets,
  postComment,
  postTweet,
  recordTweetView,
  removeTweet,
  updateTweet,
  updateTweetInteraction
} from '../controllers/tweetController.js';
import { optionalAuth, requireAuth } from '../middleware/auth.js';

const router = Router();

router.post('/auth/register', register);
router.post('/auth/login', login);
router.get('/auth/me', requireAuth, me);
router.post('/auth/avatar', requireAuth, uploadAvatar);
router.patch('/auth/profile', requireAuth, updateProfile);
router.post('/auth/logout', requireAuth, logout);

router.get('/tweets', optionalAuth, getTweets);
router.get('/tweets/:id', optionalAuth, getTweetById);
router.post('/tweets/:id/view', optionalAuth, recordTweetView);
router.post('/tweets', requireAuth, postTweet);
router.patch('/tweets/:id', requireAuth, updateTweet);
router.delete('/tweets/:id', requireAuth, removeTweet);
router.get('/tweets/:id/comments', getCommentsByTweetId);
router.post('/tweets/:id/comments', requireAuth, postComment);
router.post('/tweets/:id/:action', requireAuth, updateTweetInteraction);

export default router;
