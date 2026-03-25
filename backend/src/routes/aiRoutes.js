import { Router } from 'express';

import { chatWithAi } from '../controllers/aiController.js';
import { optionalAuth } from '../middleware/auth.js';

const router = Router();

router.post('/ai/chat', optionalAuth, chatWithAi);

export default router;
