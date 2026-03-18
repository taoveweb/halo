import { pool } from '../db/mysql.js';

export async function requireAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    if (!authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const token = authHeader.slice(7).trim();
    if (!token) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const [rows] = await pool.query(
      `SELECT u.id, u.email, u.name, u.handle, u.avatar_url
       FROM auth_tokens t
       INNER JOIN users u ON u.id = t.user_id
       WHERE t.token = ? AND t.expires_at > NOW()
       LIMIT 1`,
      [token]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    req.authToken = token;
    req.authUser = rows[0];
    return next();
  } catch (error) {
    return next(error);
  }
}
