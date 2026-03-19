import { pool } from '../db/mysql.js';

const DEFAULT_USER_HANDLE = '@you';

function parseBool(value) {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    if (value.toLowerCase() === 'true') return true;
    if (value.toLowerCase() === 'false') return false;
  }
  return null;
}

function mapTopic(row) {
  return {
    id: String(row.id),
    title: row.title,
    posts: row.posts,
    following: Boolean(row.following)
  };
}

export async function getTopics(req, res, next) {
  try {
    const query = req.query.query?.trim();
    const [rows] = await pool.query(
      `SELECT
         t.*,
         CASE WHEN utf.topic_id IS NULL THEN 0 ELSE 1 END AS following
       FROM topics t
       LEFT JOIN user_topic_follows utf
         ON utf.topic_id = t.id
        AND utf.user_handle = ?
       WHERE (? IS NULL OR t.title LIKE CONCAT('%', ?, '%'))
       ORDER BY t.posts DESC, t.id ASC`,
      [DEFAULT_USER_HANDLE, query ?? null, query ?? null]
    );

    return res.status(200).json(rows.map(mapTopic));
  } catch (error) {
    next(error);
  }
}

export async function createTopic(req, res, next) {
  try {
    const rawTitle = req.body.title;
    if (typeof rawTitle !== 'string' || !rawTitle.trim()) {
      return res.status(400).json({ message: 'title is required' });
    }

    const normalizedTitle = rawTitle.trim().startsWith('#')
      ? rawTitle.trim()
      : `#${rawTitle.trim()}`;
    if (normalizedTitle.length > 80) {
      return res.status(400).json({ message: 'title must be <= 80 chars' });
    }

    await pool.query(
      `INSERT INTO topics (title, posts)
       VALUES (?, 0)
       ON DUPLICATE KEY UPDATE title = title`,
      [normalizedTitle]
    );

    const [rows] = await pool.query(
      `SELECT
         t.*,
         CASE WHEN utf.topic_id IS NULL THEN 0 ELSE 1 END AS following
       FROM topics t
       LEFT JOIN user_topic_follows utf
         ON utf.topic_id = t.id
        AND utf.user_handle = ?
       WHERE t.title = ?
       LIMIT 1`,
      [DEFAULT_USER_HANDLE, normalizedTitle]
    );

    return res.status(201).json(mapTopic(rows[0]));
  } catch (error) {
    next(error);
  }
}

export async function updateTopicFollow(req, res, next) {
  try {
    const topicId = req.params.id;
    const active = parseBool(req.body.active);
    if (active === null) {
      return res.status(400).json({ message: 'active must be boolean' });
    }

    const [rows] = await pool.query('SELECT id FROM topics WHERE id = ? LIMIT 1', [topicId]);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Topic not found' });
    }

    if (active) {
      await pool.query(
        `INSERT IGNORE INTO user_topic_follows (user_handle, topic_id)
         VALUES (?, ?)`,
        [DEFAULT_USER_HANDLE, topicId]
      );
    } else {
      await pool.query('DELETE FROM user_topic_follows WHERE user_handle = ? AND topic_id = ?', [
        DEFAULT_USER_HANDLE,
        topicId
      ]);
    }

    const [topicRows] = await pool.query(
      `SELECT
         t.*,
         CASE WHEN utf.topic_id IS NULL THEN 0 ELSE 1 END AS following
       FROM topics t
       LEFT JOIN user_topic_follows utf
         ON utf.topic_id = t.id
        AND utf.user_handle = ?
       WHERE t.id = ?
       LIMIT 1`,
      [DEFAULT_USER_HANDLE, topicId]
    );

    return res.status(200).json(mapTopic(topicRows[0]));
  } catch (error) {
    next(error);
  }
}
