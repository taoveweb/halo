import { pool } from '../db/mysql.js';

function mapTweet(row) {
  return {
    id: String(row.id),
    author: row.author,
    handle: row.handle,
    content: row.content,
    createdAt: new Date(row.created_at).toISOString(),
    likes: row.likes,
    comments: row.comments,
    retweets: row.retweets
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

export async function getTweets(_req, res, next) {
  try {
    const [rows] = await pool.query('SELECT * FROM tweets ORDER BY created_at DESC, id DESC');
    res.status(200).json(rows.map(mapTweet));
  } catch (error) {
    next(error);
  }
}

export async function getTweetById(req, res, next) {
  try {
    const [rows] = await pool.query('SELECT * FROM tweets WHERE id = ? LIMIT 1', [req.params.id]);
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

    const [rows] = await pool.query('SELECT * FROM tweets WHERE id = ? LIMIT 1', [result.insertId]);
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
    return res.status(201).json(mapComment(rows[0]));
  } catch (error) {
    next(error);
  }
}
