import { randomBytes } from 'node:crypto';

import { pool } from '../db/mysql.js';
import { hashPassword, verifyPassword } from '../utils/password.js';

function mapUser(row) {
  return {
    id: String(row.id),
    email: row.email,
    name: row.name,
    handle: row.handle
  };
}

function normalizeHandle(handle) {
  const cleaned = handle.trim().replace(/^@+/, '');
  return `@${cleaned}`;
}

function createSessionToken() {
  return randomBytes(32).toString('hex');
}

async function createLoginResponse(userId) {
  const token = createSessionToken();
  await pool.query(
    `INSERT INTO auth_tokens (token, user_id, expires_at)
     VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 30 DAY))`,
    [token, userId]
  );

  const [rows] = await pool.query('SELECT id, email, name, handle FROM users WHERE id = ? LIMIT 1', [userId]);
  return {
    token,
    user: mapUser(rows[0])
  };
}

export async function register(req, res, next) {
  try {
    const email = req.body.email?.trim().toLowerCase();
    const password = req.body.password?.trim();
    const name = req.body.name?.trim();
    const handleRaw = req.body.handle?.trim();

    if (!email || !password || !name || !handleRaw) {
      return res.status(400).json({ message: 'name, handle, email and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ message: 'password must be at least 6 characters' });
    }

    const handle = normalizeHandle(handleRaw);
    if (handle.length < 2 || handle.length > 80) {
      return res.status(400).json({ message: 'handle length is invalid' });
    }

    const passwordHash = hashPassword(password);

    try {
      const [result] = await pool.query(
        `INSERT INTO users (email, password_hash, name, handle)
         VALUES (?, ?, ?, ?)`,
        [email, passwordHash, name, handle]
      );
      const loginResponse = await createLoginResponse(result.insertId);
      return res.status(201).json(loginResponse);
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ message: 'email or handle already exists' });
      }
      throw error;
    }
  } catch (error) {
    return next(error);
  }
}

export async function login(req, res, next) {
  try {
    const email = req.body.email?.trim().toLowerCase();
    const password = req.body.password?.trim();

    if (!email || !password) {
      return res.status(400).json({ message: 'email and password are required' });
    }

    const [rows] = await pool.query(
      'SELECT id, email, name, handle, password_hash FROM users WHERE email = ? LIMIT 1',
      [email]
    );

    if (rows.length === 0 || !verifyPassword(password, rows[0].password_hash)) {
      return res.status(401).json({ message: 'invalid email or password' });
    }

    const loginResponse = await createLoginResponse(rows[0].id);
    return res.status(200).json(loginResponse);
  } catch (error) {
    return next(error);
  }
}

export async function me(req, res) {
  return res.status(200).json(mapUser(req.authUser));
}

export async function logout(req, res, next) {
  try {
    await pool.query('DELETE FROM auth_tokens WHERE token = ?', [req.authToken]);
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}
