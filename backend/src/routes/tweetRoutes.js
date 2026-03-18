import { Router } from 'express';

import { getTweetById, getTweets, postTweet } from '../controllers/tweetController.js';

const router = Router();

router.get('/tweets', getTweets);
router.get('/tweets/:id', getTweetById);
router.post('/tweets', postTweet);

export default router;
