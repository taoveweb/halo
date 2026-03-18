import { randomBytes } from 'node:crypto';

const SESSION_TTL_MS = 1000 * 60 * 60 * 8;
const adminSessions = new Map();

function cleanupExpiredSessions() {
  const now = Date.now();
  for (const [token, session] of adminSessions.entries()) {
    if (session.expiresAt <= now) {
      adminSessions.delete(token);
    }
  }
}

export function createAdminSession(username) {
  cleanupExpiredSessions();
  const token = randomBytes(32).toString('hex');
  adminSessions.set(token, {
    username,
    expiresAt: Date.now() + SESSION_TTL_MS
  });
  return token;
}

export function getAdminSession(token) {
  cleanupExpiredSessions();
  return adminSessions.get(token) || null;
}

export function deleteAdminSession(token) {
  adminSessions.delete(token);
}
