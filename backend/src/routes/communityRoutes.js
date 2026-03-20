import { Router } from 'express';

import { getCommunities, updateCommunityJoin } from '../controllers/communityController.js';
import { optionalAuth, requireAuth } from '../middleware/auth.js';

const router = Router();

router.get('/communities', optionalAuth, getCommunities);
router.post('/communities/:id/join', requireAuth, updateCommunityJoin);

export default router;
