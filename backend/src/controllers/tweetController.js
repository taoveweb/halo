import { pool } from '../db/mysql.js';

const DEFAULT_USER_HANDLE = '@you';
const HASHTAG_PATTERN = /#[\p{L}\p{N}_]+/gu;

function parseBool(value) {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    if (value.toLowerCase() === 'true') return true;
    if (value.toLowerCase() === 'false') return false;
  }
  return null;
}

function mapTweet(row) {
  return {
    id: String(row.id),
    author: row.author,
    handle: row.handle,
    content: row.content,
    createdAt: new Date(row.created_at).toISOString(),
    likes: row.likes,
    comments: row.comments,
    retweets: row.retweets,
    isLiked: Boolean(row.is_liked),
    isRetweeted: Boolean(row.is_retweeted)
  };
}

function mapComment(row) {
  return {
    id: String(row.id),
    tweetId: String(row.tweet_id),
    author: row.author,
    handle: row.handle,
    content: row.content,
    createdAt: new Date(row.created_at).toISOString()
  };
}

async function hydrateTweetStats(tweetId) {
  await pool.query(
    `UPDATE tweets
     SET likes = (SELECT COUNT(*) FROM tweet_interactions WHERE tweet_id = ? AND liked = 1),
         retweets = (SELECT COUNT(*) FROM tweet_interactions WHERE tweet_id = ? AND retweeted = 1)
     WHERE id = ?`,
    [tweetId, tweetId, tweetId]
  );
}

async function upsertTopicsByContent(content) {
  const matches = content.match(HASHTAG_PATTERN) ?? [];
  if (matches.length === 0) {
    return;
  }

  const uniqueTopics = [...new Set(matches.map((topic) => topic.trim()).filter(Boolean))].slice(0, 20);

  for (const title of uniqueTopics) {
    await pool.query(
      `INSERT INTO topics (title, posts)
       VALUES (?, 1)
       ON DUPLICATE KEY UPDATE posts = posts + 1`,
      [title]
    );
  }
}

export async function getTweets(req, res, next) {
  try {
    const viewerHandle = req.query.viewerHandle?.trim() || DEFAULT_USER_HANDLE;
    const feed = req.query.feed === 'following' ? 'following' : 'for_you';
    const query = req.query.query?.trim() || '';
    const hasQuery = query.length > 0;
    const queryCondition = hasQuery ? ' AND t.content LIKE ?' : '';
    const queryParam = hasQuery ? [`%${query}%`] : [];

    const baseQuery = `
      SELECT
        t.*,
        COALESCE(ti.liked, 0) AS is_liked,
        COALESCE(ti.retweeted, 0) AS is_retweeted
      FROM tweets t
      LEFT JOIN tweet_interactions ti
        ON ti.tweet_id = t.id
       AND ti.user_handle = ?
    `;

    if (feed === 'following') {
      const [rows] = await pool.query(
        `${baseQuery}
         WHERE (
           t.handle = ?
           OR t.handle IN (
             SELECT target_handle
             FROM user_following
             WHERE user_handle = ?
           )
         )
         ${queryCondition}
         ORDER BY t.created_at DESC, t.id DESC`,
        [viewerHandle, viewerHandle, viewerHandle, ...queryParam]
      );
      return res.status(200).json(rows.map(mapTweet));
    }

    const [rows] = await pool.query(
      `${baseQuery}
       ${hasQuery ? 'WHERE t.content LIKE ?' : ''}
       ORDER BY (t.likes * 2 + t.retweets * 3 + t.comments) DESC, t.created_at DESC, t.id DESC`,
      [viewerHandle, ...queryParam]
    );
    return res.status(200).json(rows.map(mapTweet));
  } catch (error) {
    next(error);
  }
}

export async function getTweetById(req, res, next) {
  try {
    const viewerHandle = req.query.viewerHandle?.trim() || DEFAULT_USER_HANDLE;
    const [rows] = await pool.query(
      `SELECT
         t.*,
         COALESCE(ti.liked, 0) AS is_liked,
         COALESCE(ti.retweeted, 0) AS is_retweeted
       FROM tweets t
       LEFT JOIN tweet_interactions ti
         ON ti.tweet_id = t.id
        AND ti.user_handle = ?
       WHERE t.id = ?
       LIMIT 1`,
      [viewerHandle, req.params.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Tweet not found' });
    }

    return res.status(200).json(mapTweet(rows[0]));
  } catch (error) {
    next(error);
  }
}

export async function postTweet(req, res, next) {
  try {
    const { content } = req.body;
    if (!content || !content.trim()) {
      return res.status(400).json({ message: 'content is required' });
    }

    const normalizedContent = content.trim();
    if (normalizedContent.length > 280) {
      return res.status(400).json({ message: 'content must be <= 280 chars' });
    }

    const normalizedAuthor = req.authUser.name;
    const normalizedHandle = req.authUser.handle;

    const [result] = await pool.query(
      `INSERT INTO tweets (author, handle, content, likes, comments, retweets)
       VALUES (?, ?, ?, 0, 0, 0)`,
      [normalizedAuthor, normalizedHandle, normalizedContent]
    );
    await upsertTopicsByContent(normalizedContent);

    const [rows] = await pool.query(
      `SELECT t.*, 0 AS is_liked, 0 AS is_retweeted
       FROM tweets t
       WHERE id = ?
       LIMIT 1`,
      [result.insertId]
    );

    return res.status(201).json(mapTweet(rows[0]));
  } catch (error) {
    next(error);
  }
}

export async function getCommentsByTweetId(req, res, next) {
  try {
    const [tweetRows] = await pool.query('SELECT id FROM tweets WHERE id = ? LIMIT 1', [req.params.id]);
    if (tweetRows.length === 0) {
      return res.status(404).json({ message: 'Tweet not found' });
    }

    const [rows] = await pool.query(
      'SELECT * FROM comments WHERE tweet_id = ? ORDER BY created_at ASC, id ASC',
      [req.params.id]
    );
    return res.status(200).json(rows.map(mapComment));
  } catch (error) {
    next(error);
  }
}

export async function postComment(req, res, next) {
  try {
    const { content } = req.body;
    if (!content || !content.trim()) {
      return res.status(400).json({ message: 'content is required' });
    }

    const normalizedContent = content.trim();
    if (normalizedContent.length > 280) {
      return res.status(400).json({ message: 'content must be <= 280 chars' });
    }

    const [tweetRows] = await pool.query('SELECT id FROM tweets WHERE id = ? LIMIT 1', [req.params.id]);
    if (tweetRows.length === 0) {
      return res.status(404).json({ message: 'Tweet not found' });
    }

    const normalizedAuthor = req.authUser.name;
    const normalizedHandle = req.authUser.handle;

    const [result] = await pool.query(
      `INSERT INTO comments (tweet_id, author, handle, content)
       VALUES (?, ?, ?, ?)`,
      [req.params.id, normalizedAuthor, normalizedHandle, normalizedContent]
    );

    await pool.query('UPDATE tweets SET comments = comments + 1 WHERE id = ?', [req.params.id]);

    const [rows] = await pool.query('SELECT * FROM comments WHERE id = ? LIMIT 1', [result.insertId]);
    return res.status(201).json(rows.map(mapComment)[0]);
  } catch (error) {
    next(error);
  }
}

export async function updateTweetInteraction(req, res, next) {
  try {
    const { id } = req.params;
    const action = req.params.action;
    const active = parseBool(req.body.active);
    if (active === null) {
      return res.status(400).json({ message: 'active must be boolean' });
    }

    if (!['like', 'retweet'].includes(action)) {
      return res.status(400).json({ message: 'invalid action' });
    }

    const [tweetRows] = await pool.query('SELECT id FROM tweets WHERE id = ? LIMIT 1', [id]);
    if (tweetRows.length === 0) {
      return res.status(404).json({ message: 'Tweet not found' });
    }

    const field = action === 'like' ? 'liked' : 'retweeted';

    await pool.query(
      `INSERT INTO tweet_interactions (tweet_id, user_handle, liked, retweeted)
       VALUES (?, ?, 0, 0)
       ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP`,
      [id, DEFAULT_USER_HANDLE]
    );

    await pool.query(
      `UPDATE tweet_interactions
       SET ${field} = ?, updated_at = CURRENT_TIMESTAMP
       WHERE tweet_id = ? AND user_handle = ?`,
      [active ? 1 : 0, id, DEFAULT_USER_HANDLE]
    );

    await hydrateTweetStats(id);

    const [rows] = await pool.query(
      `SELECT
         t.*,
         COALESCE(ti.liked, 0) AS is_liked,
         COALESCE(ti.retweeted, 0) AS is_retweeted
       FROM tweets t
       LEFT JOIN tweet_interactions ti
         ON ti.tweet_id = t.id
        AND ti.user_handle = ?
       WHERE t.id = ?
       LIMIT 1`,
      [DEFAULT_USER_HANDLE, id]
    );

    return res.status(200).json(mapTweet(rows[0]));
  } catch (error) {
    next(error);
  }
}
