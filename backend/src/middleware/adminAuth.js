import { getAdminSession } from '../services/adminSessionService.js';

export function requireAdminAuth(req, res, next) {
  const authHeader = req.headers.authorization || '';
  if (!authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Unauthorized admin access' });
  }

  const token = authHeader.slice(7).trim();
  if (!token) {
    return res.status(401).json({ message: 'Unauthorized admin access' });
  }

  const session = getAdminSession(token);
  if (!session) {
    return res.status(401).json({ message: 'Admin session expired or invalid' });
  }

  req.adminToken = token;
  req.adminUser = {
    username: session.username
  };

  return next();
}
