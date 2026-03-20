import { Router } from 'express';

import { createTopic, getTopics, updateTopicFollow } from '../controllers/topicController.js';
import { optionalAuth, requireAuth } from '../middleware/auth.js';

const router = Router();

router.get('/topics', optionalAuth, getTopics);
router.post('/topics', requireAuth, createTopic);
router.post('/topics/:id/follow', requireAuth, updateTopicFollow);

export default router;
