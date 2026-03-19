import { pool } from '../db/mysql.js';
import { deleteAdminSession, createAdminSession } from '../services/adminSessionService.js';

const DEFAULT_ADMIN_USERNAME = 'admin';
const DEFAULT_ADMIN_PASSWORD = 'admin123456';
const LOGIN_LOCK_WINDOW_MS = 1000 * 60 * 15;
const LOGIN_MAX_ATTEMPTS = 5;

const loginAttemptStore = new Map();

function getAdminCredentials() {
  return {
    username: process.env.ADMIN_USERNAME?.trim() || DEFAULT_ADMIN_USERNAME,
    password: process.env.ADMIN_PASSWORD?.trim() || DEFAULT_ADMIN_PASSWORD
  };
}

function getRateLimitState(username) {
  const key = username.toLowerCase();
  const current = loginAttemptStore.get(key);

  if (!current) {
    return {
      key,
      state: {
        attempts: 0,
        lockedUntil: 0,
        lastAttemptAt: Date.now()
      }
    };
  }

  if (Date.now() - current.lastAttemptAt > LOGIN_LOCK_WINDOW_MS) {
    return {
      key,
      state: {
        attempts: 0,
        lockedUntil: 0,
        lastAttemptAt: Date.now()
      }
    };
  }

  return { key, state: current };
}

function recordFailedAttempt(username) {
  const { key, state } = getRateLimitState(username);
  const nextAttempts = state.attempts + 1;
  const nextState = {
    attempts: nextAttempts,
    lockedUntil: nextAttempts >= LOGIN_MAX_ATTEMPTS ? Date.now() + LOGIN_LOCK_WINDOW_MS : 0,
    lastAttemptAt: Date.now()
  };

  loginAttemptStore.set(key, nextState);
  return nextState;
}

function clearFailedAttempts(username) {
  loginAttemptStore.delete(username.toLowerCase());
}

async function writeAdminAuditLog(action, targetType, targetId, detail, operator = 'system') {
  await pool.query(
    `INSERT INTO admin_audit_logs (operator, action, target_type, target_id, detail)
     VALUES (?, ?, ?, ?, ?)`,
    [operator, action, targetType, targetId, detail]
  );
}

export async function adminLogin(req, res, next) {
  try {
    const username = req.body.username?.trim();
    const password = req.body.password?.trim();

    if (!username || !password) {
      return res.status(400).json({ message: 'username and password are required' });
    }

    const { state } = getRateLimitState(username);
    if (state.lockedUntil > Date.now()) {
      const waitSeconds = Math.ceil((state.lockedUntil - Date.now()) / 1000);
      return res.status(429).json({
        message: `too many failed attempts, retry in ${waitSeconds} seconds`
      });
    }

    const creds = getAdminCredentials();
    if (username !== creds.username || password !== creds.password) {
      const failedState = recordFailedAttempt(username);
      return res.status(401).json({
        message: 'invalid admin credentials',
        remainingAttempts: Math.max(LOGIN_MAX_ATTEMPTS - failedState.attempts, 0)
      });
    }

    clearFailedAttempts(username);
    const token = createAdminSession(username);

    await writeAdminAuditLog('login', 'admin', username, 'admin user logged in', username);

    return res.status(200).json({
      token,
      admin: {
        username
      }
    });
  } catch (error) {
    return next(error);
  }
}

export async function adminMe(req, res) {
  return res.status(200).json(req.adminUser);
}

export async function adminLogout(req, res, next) {
  try {
    deleteAdminSession(req.adminToken);
    await writeAdminAuditLog('logout', 'admin', req.adminUser.username, 'admin user logged out', req.adminUser.username);
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}

export async function getAdminDashboard(req, res, next) {
  try {
    const [[userCountRow]] = await pool.query('SELECT COUNT(*) AS count FROM users');
    const [[tweetCountRow]] = await pool.query('SELECT COUNT(*) AS count FROM tweets');
    const [[commentCountRow]] = await pool.query('SELECT COUNT(*) AS count FROM comments');

    const [[newUsersTodayRow]] = await pool.query(
      'SELECT COUNT(*) AS count FROM users WHERE DATE(created_at) = CURRENT_DATE()'
    );
    const [[tweetsTodayRow]] = await pool.query(
      'SELECT COUNT(*) AS count FROM tweets WHERE DATE(created_at) = CURRENT_DATE()'
    );
    const [[commentsTodayRow]] = await pool.query(
      'SELECT COUNT(*) AS count FROM comments WHERE DATE(created_at) = CURRENT_DATE()'
    );

    const [recentTweets] = await pool.query(
      `SELECT id, author AS authorName, handle AS authorHandle, content, created_at AS createdAt
       FROM tweets
       ORDER BY created_at DESC
       LIMIT 10`
    );

    return res.status(200).json({
      counts: {
        users: userCountRow.count,
        tweets: tweetCountRow.count,
        comments: commentCountRow.count
      },
      daily: {
        users: newUsersTodayRow.count,
        tweets: tweetsTodayRow.count,
        comments: commentsTodayRow.count
      },
      recentTweets
    });
  } catch (error) {
    return next(error);
  }
}

export async function getAdminTweets(req, res, next) {
  try {
    const page = Math.max(Number.parseInt(req.query.page ?? '1', 10), 1);
    const pageSize = Math.min(Math.max(Number.parseInt(req.query.pageSize ?? '10', 10), 1), 50);
    const keyword = req.query.keyword?.trim() || '';

    const whereClause = keyword ? 'WHERE content LIKE ? OR author LIKE ? OR handle LIKE ?' : '';
    const params = keyword ? [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`] : [];

    const [[countRow]] = await pool.query(`SELECT COUNT(*) AS count FROM tweets ${whereClause}`, params);

    const [rows] = await pool.query(
      `SELECT id, author AS authorName, handle AS authorHandle, content, created_at AS createdAt
       FROM tweets
       ${whereClause}
       ORDER BY created_at DESC
       LIMIT ? OFFSET ?`,
      [...params, pageSize, (page - 1) * pageSize]
    );

    return res.status(200).json({
      list: rows,
      pagination: {
        page,
        pageSize,
        total: countRow.count
      }
    });
  } catch (error) {
    return next(error);
  }
}

export async function getAdminUsers(req, res, next) {
  try {
    const page = Math.max(Number.parseInt(req.query.page ?? '1', 10), 1);
    const pageSize = Math.min(Math.max(Number.parseInt(req.query.pageSize ?? '10', 10), 1), 50);
    const keyword = req.query.keyword?.trim() || '';

    const whereClause = keyword ? 'WHERE name LIKE ? OR handle LIKE ? OR email LIKE ?' : '';
    const params = keyword ? [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`] : [];

    const [[countRow]] = await pool.query(`SELECT COUNT(*) AS count FROM users ${whereClause}`, params);

    const [rows] = await pool.query(
      `SELECT id, name, handle, email, created_at AS createdAt
       FROM users
       ${whereClause}
       ORDER BY created_at DESC
       LIMIT ? OFFSET ?`,
      [...params, pageSize, (page - 1) * pageSize]
    );

    return res.status(200).json({
      list: rows,
      pagination: {
        page,
        pageSize,
        total: countRow.count
      }
    });
  } catch (error) {
    return next(error);
  }
}

export async function getAdminComments(req, res, next) {
  try {
    const page = Math.max(Number.parseInt(req.query.page ?? '1', 10), 1);
    const pageSize = Math.min(Math.max(Number.parseInt(req.query.pageSize ?? '10', 10), 1), 50);
    const keyword = req.query.keyword?.trim() || '';

    const whereClause = keyword ? 'WHERE c.content LIKE ? OR c.author LIKE ? OR c.handle LIKE ?' : '';
    const params = keyword ? [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`] : [];

    const [[countRow]] = await pool.query(`SELECT COUNT(*) AS count FROM comments c ${whereClause}`, params);

    const [rows] = await pool.query(
      `SELECT c.id, c.tweet_id AS tweetId, c.author, c.handle, c.content, c.created_at AS createdAt,
              t.content AS tweetContent
       FROM comments c
       LEFT JOIN tweets t ON t.id = c.tweet_id
       ${whereClause}
       ORDER BY c.created_at DESC
       LIMIT ? OFFSET ?`,
      [...params, pageSize, (page - 1) * pageSize]
    );

    return res.status(200).json({
      list: rows,
      pagination: {
        page,
        pageSize,
        total: countRow.count
      }
    });
  } catch (error) {
    return next(error);
  }
}

export async function deleteAdminTweet(req, res, next) {
  try {
    const { id } = req.params;
    const [result] = await pool.query('DELETE FROM tweets WHERE id = ? LIMIT 1', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'tweet not found' });
    }

    await writeAdminAuditLog('delete', 'tweet', id, 'tweet deleted by admin', req.adminUser.username);
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}

export async function deleteAdminComment(req, res, next) {
  try {
    const { id } = req.params;
    const [result] = await pool.query('DELETE FROM comments WHERE id = ? LIMIT 1', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'comment not found' });
    }

    await writeAdminAuditLog('delete', 'comment', id, 'comment deleted by admin', req.adminUser.username);
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}

export async function getAdminAuditLogs(req, res, next) {
  try {
    const page = Math.max(Number.parseInt(req.query.page ?? '1', 10), 1);
    const pageSize = Math.min(Math.max(Number.parseInt(req.query.pageSize ?? '20', 10), 1), 100);

    const [[countRow]] = await pool.query('SELECT COUNT(*) AS count FROM admin_audit_logs');
    const [rows] = await pool.query(
      `SELECT id, operator, action, target_type AS targetType, target_id AS targetId, detail, created_at AS createdAt
       FROM admin_audit_logs
       ORDER BY created_at DESC
       LIMIT ? OFFSET ?`,
      [pageSize, (page - 1) * pageSize]
    );

    return res.status(200).json({
      list: rows,
      pagination: {
        page,
        pageSize,
        total: countRow.count
      }
    });
  } catch (error) {
    return next(error);
  }
}
