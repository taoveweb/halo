import { Router } from 'express';

import { createTopic, getTopics, updateTopicFollow } from '../controllers/topicController.js';

const router = Router();

router.get('/topics', getTopics);
router.post('/topics', createTopic);
router.post('/topics/:id/follow', updateTopicFollow);

export default router;
