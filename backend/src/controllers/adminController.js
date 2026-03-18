import { pool } from '../db/mysql.js';
import { deleteAdminSession, createAdminSession } from '../services/adminSessionService.js';

const DEFAULT_ADMIN_USERNAME = 'admin';
const DEFAULT_ADMIN_PASSWORD = 'admin123456';

function getAdminCredentials() {
  return {
    username: process.env.ADMIN_USERNAME?.trim() || DEFAULT_ADMIN_USERNAME,
    password: process.env.ADMIN_PASSWORD?.trim() || DEFAULT_ADMIN_PASSWORD
  };
}

export async function adminLogin(req, res, next) {
  try {
    const username = req.body.username?.trim();
    const password = req.body.password?.trim();
    if (!username || !password) {
      return res.status(400).json({ message: 'username and password are required' });
    }

    const creds = getAdminCredentials();
    if (username !== creds.username || password !== creds.password) {
      return res.status(401).json({ message: 'invalid admin credentials' });
    }

    const token = createAdminSession(username);
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

export async function adminLogout(req, res) {
  deleteAdminSession(req.adminToken);
  return res.status(204).send();
}

export async function getAdminDashboard(req, res, next) {
  try {
    const [[userCountRow]] = await pool.query('SELECT COUNT(*) AS count FROM users');
    const [[tweetCountRow]] = await pool.query('SELECT COUNT(*) AS count FROM tweets');
    const [[commentCountRow]] = await pool.query('SELECT COUNT(*) AS count FROM comments');

    const [recentTweets] = await pool.query(
      `SELECT id, author_name AS authorName, author_handle AS authorHandle, content, created_at AS createdAt
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

    const whereClause = keyword ? 'WHERE content LIKE ? OR author_name LIKE ? OR author_handle LIKE ?' : '';
    const params = keyword ? [`%${keyword}%`, `%${keyword}%`, `%${keyword}%`] : [];

    const [[countRow]] = await pool.query(`SELECT COUNT(*) AS count FROM tweets ${whereClause}`, params);

    const [rows] = await pool.query(
      `SELECT id, user_id AS userId, author_name AS authorName, author_handle AS authorHandle, content, created_at AS createdAt
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

export async function deleteAdminTweet(req, res, next) {
  try {
    const { id } = req.params;
    const [result] = await pool.query('DELETE FROM tweets WHERE id = ? LIMIT 1', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'tweet not found' });
    }

    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}
