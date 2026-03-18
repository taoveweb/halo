import { randomBytes } from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { pool } from '../db/mysql.js';
import { hashPassword, verifyPassword } from '../utils/password.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const uploadDir = path.join(__dirname, '../../uploads');

function mapUser(row) {
  return {
    id: String(row.id),
    email: row.email,
    name: row.name,
    handle: row.handle,
    avatarUrl: row.avatar_url
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

  const [rows] = await pool.query('SELECT id, email, name, handle, avatar_url FROM users WHERE id = ? LIMIT 1', [
    userId
  ]);
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
    const avatarUrl = req.body.avatarUrl?.trim() || null;

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
        `INSERT INTO users (email, password_hash, name, handle, avatar_url)
         VALUES (?, ?, ?, ?, ?)`,
        [email, passwordHash, name, handle, avatarUrl]
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
      'SELECT id, email, name, handle, avatar_url, password_hash FROM users WHERE email = ? LIMIT 1',
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

export async function uploadAvatar(req, res, next) {
  try {
    const imageBase64 = req.body.imageBase64?.trim();
    if (!imageBase64) {
      return res.status(400).json({ message: 'imageBase64 is required' });
    }

    const dataUrlMatch = imageBase64.match(/^data:(image\/[a-zA-Z0-9.+-]+);base64,(.+)$/);
    if (!dataUrlMatch) {
      return res.status(400).json({ message: 'invalid imageBase64 format' });
    }

    const mimeType = dataUrlMatch[1].toLowerCase();
    const base64Data = dataUrlMatch[2];
    const extensionMap = {
      'image/jpeg': 'jpg',
      'image/jpg': 'jpg',
      'image/png': 'png',
      'image/webp': 'webp',
      'image/gif': 'gif'
    };
    const ext = extensionMap[mimeType];
    if (!ext) {
      return res.status(400).json({ message: 'unsupported image type' });
    }

    const buffer = Buffer.from(base64Data, 'base64');
    if (!buffer.length) {
      return res.status(400).json({ message: 'invalid image payload' });
    }

    const maxBytes = 5 * 1024 * 1024;
    if (buffer.length > maxBytes) {
      return res.status(400).json({ message: 'image size exceeds 5MB limit' });
    }

    await fs.mkdir(uploadDir, { recursive: true });
    const filename = `avatar-${Date.now()}-${randomBytes(6).toString('hex')}.${ext}`;
    await fs.writeFile(path.join(uploadDir, filename), buffer);

    const host = `${req.protocol}://${req.get('host')}`;
    const avatarUrl = `${host}/uploads/${filename}`;
    return res.status(201).json({ avatarUrl });
  } catch (error) {
    return next(error);
  }
}

export async function updateProfile(req, res, next) {
  try {
    const userId = req.authUser.id;
    const updates = {};

    if (typeof req.body.name === 'string') {
      const nextName = req.body.name.trim();
      if (!nextName) {
        return res.status(400).json({ message: 'name cannot be empty' });
      }
      updates.name = nextName;
    }

    if (typeof req.body.handle === 'string') {
      const handle = normalizeHandle(req.body.handle);
      if (handle.length < 2 || handle.length > 80) {
        return res.status(400).json({ message: 'handle length is invalid' });
      }
      updates.handle = handle;
    }

    if (typeof req.body.avatarUrl === 'string' || req.body.avatarUrl === null) {
      const avatarUrl = typeof req.body.avatarUrl === 'string' ? req.body.avatarUrl.trim() : null;
      updates.avatar_url = avatarUrl || null;
    }

    if (typeof req.body.email === 'string') {
      const email = req.body.email.trim().toLowerCase();
      if (!email) {
        return res.status(400).json({ message: 'email cannot be empty' });
      }
      updates.email = email;
    }

    if (req.body.newPassword != null) {
      const currentPassword = req.body.currentPassword?.trim();
      const newPassword = req.body.newPassword?.trim();

      if (!currentPassword || !newPassword) {
        return res.status(400).json({ message: 'currentPassword and newPassword are required to change password' });
      }

      if (newPassword.length < 6) {
        return res.status(400).json({ message: 'new password must be at least 6 characters' });
      }

      const [rows] = await pool.query('SELECT password_hash FROM users WHERE id = ? LIMIT 1', [userId]);
      if (rows.length === 0 || !verifyPassword(currentPassword, rows[0].password_hash)) {
        return res.status(401).json({ message: 'current password is incorrect' });
      }

      updates.password_hash = hashPassword(newPassword);
    }

    const fields = Object.keys(updates);
    if (fields.length === 0) {
      return res.status(400).json({ message: 'no updatable fields were provided' });
    }

    const setClause = fields.map((field) => `${field} = ?`).join(', ');
    const values = fields.map((field) => updates[field]);

    try {
      await pool.query(`UPDATE users SET ${setClause} WHERE id = ?`, [...values, userId]);
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ message: 'email or handle already exists' });
      }
      throw error;
    }

    const [rows] = await pool.query('SELECT id, email, name, handle, avatar_url FROM users WHERE id = ? LIMIT 1', [
      userId
    ]);
    return res.status(200).json(mapUser(rows[0]));
  } catch (error) {
    return next(error);
  }
}

export async function logout(req, res, next) {
  try {
    await pool.query('DELETE FROM auth_tokens WHERE token = ?', [req.authToken]);
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}
