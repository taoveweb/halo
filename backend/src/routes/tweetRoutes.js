import { Router } from 'express';

import {
  getCommentsByTweetId,
  getTweetById,
  getTweets,
  postComment,
  postTweet
} from '../controllers/tweetController.js';

const router = Router();

router.get('/tweets', getTweets);
router.get('/tweets/:id', getTweetById);
router.post('/tweets', postTweet);
router.get('/tweets/:id/comments', getCommentsByTweetId);
router.post('/tweets/:id/comments', postComment);

export default router;
