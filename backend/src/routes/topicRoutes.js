import { Router } from 'express';

import { getTopics, updateTopicFollow } from '../controllers/topicController.js';

const router = Router();

router.get('/topics', getTopics);
router.post('/topics/:id/follow', updateTopicFollow);

export default router;
