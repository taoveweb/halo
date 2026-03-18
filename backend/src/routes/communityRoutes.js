import { Router } from 'express';

import { getCommunities, updateCommunityJoin } from '../controllers/communityController.js';

const router = Router();

router.get('/communities', getCommunities);
router.post('/communities/:id/join', updateCommunityJoin);

export default router;
