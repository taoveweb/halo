import { Router } from 'express';

import {
  getCommentsByTweetId,
  getTweetById,
  getTweets,
  postComment,
  postTweet,
  updateTweetInteraction
} from '../controllers/tweetController.js';

const router = Router();

router.get('/tweets', getTweets);
router.get('/tweets/:id', getTweetById);
router.post('/tweets', postTweet);
router.get('/tweets/:id/comments', getCommentsByTweetId);
router.post('/tweets/:id/comments', postComment);
router.post('/tweets/:id/:action', updateTweetInteraction);

export default router;
