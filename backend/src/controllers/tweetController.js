import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { pool } from '../db/mysql.js';
import { pushNotificationToHandle } from './socialController.js';

const DEFAULT_USER_HANDLE = '@you';
const HASHTAG_PATTERN = /#[\p{L}\p{N}_]+/gu;
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const uploadDir = path.join(__dirname, '../../uploads');
const MAX_TWEET_MEDIA_COUNT = 4;
const MAX_IMAGE_SIZE = 8 * 1024 * 1024;
const MAX_VIDEO_SIZE = 40 * 1024 * 1024;

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
    views: Number.isFinite(row.views) ? row.views : 0,
    isLiked: Boolean(row.is_liked),
    isRetweeted: Boolean(row.is_retweeted),
    media: []
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

function detectMediaType(mimeType) {
  if (mimeType.startsWith('image/')) return 'image';
  if (mimeType.startsWith('video/')) return 'video';
  return null;
}

function extensionFromMime(mimeType) {
  const map = {
    'image/jpeg': 'jpg',
    'image/jpg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
    'image/gif': 'gif',
    'video/mp4': 'mp4',
    'video/quicktime': 'mov',
    'video/webm': 'webm'
  };
  return map[mimeType] ?? null;
}

function mapMedia(rows) {
  return rows.map((row) => ({
    id: String(row.id),
    mediaType: row.media_type,
    mediaUrl: row.media_url,
    mimeType: row.mime_type,
    sortOrder: row.sort_order
  }));
}

async function attachMediaToTweets(tweets) {
  if (tweets.length === 0) {
    return tweets;
  }

  const ids = tweets.map((item) => Number(item.id)).filter((item) => Number.isFinite(item));
  if (ids.length === 0) {
    return tweets;
  }

  const [mediaRows] = await pool.query(
    `SELECT id, tweet_id, media_type, media_url, mime_type, sort_order
     FROM tweet_media
     WHERE tweet_id IN (?)
     ORDER BY tweet_id ASC, sort_order ASC, id ASC`,
    [ids]
  );

  const mediaByTweet = new Map();
  for (const row of mediaRows) {
    const key = String(row.tweet_id);
    if (!mediaByTweet.has(key)) {
      mediaByTweet.set(key, []);
    }
    mediaByTweet.get(key).push({
      id: String(row.id),
      mediaType: row.media_type,
      mediaUrl: row.media_url,
      mimeType: row.mime_type,
      sortOrder: row.sort_order
    });
  }

  return tweets.map((tweet) => ({
    ...tweet,
    media: mediaByTweet.get(tweet.id) ?? []
  }));
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

function extractMentionHandles(content) {
  if (!content) return [];
  const matches = content.match(/@[\w_]+/g) || [];
  // normalize to include leading @
  return [...new Set(matches.map((m) => m.trim()))];
}

async function persistTweetMedia({ tweetId, mediaItems, host }) {
  if (!Array.isArray(mediaItems) || mediaItems.length === 0) {
    return;
  }

  if (mediaItems.length > MAX_TWEET_MEDIA_COUNT) {
    throw new Error(`最多允许上传 ${MAX_TWEET_MEDIA_COUNT} 个媒体文件`);
  }

  await fs.mkdir(uploadDir, { recursive: true });

  for (let index = 0; index < mediaItems.length; index += 1) {
    const item = mediaItems[index];
    const mediaBase64 = item?.mediaBase64?.trim();

    if (!mediaBase64) {
      throw new Error('mediaBase64 is required');
    }

    const dataUrlMatch = mediaBase64.match(/^data:([a-zA-Z0-9.+/-]+);base64,(.+)$/);
    if (!dataUrlMatch) {
      throw new Error('invalid mediaBase64 format');
    }

    const mimeType = dataUrlMatch[1].toLowerCase();
    const payload = dataUrlMatch[2];
    const mediaType = detectMediaType(mimeType);
    const ext = extensionFromMime(mimeType);

    if (!mediaType || !ext) {
      throw new Error(`unsupported media type: ${mimeType}`);
    }

    const buffer = Buffer.from(payload, 'base64');
    if (!buffer || buffer.length === 0) {
      throw new Error('invalid media payload');
    }

    const maxBytes = mediaType === 'image' ? MAX_IMAGE_SIZE : MAX_VIDEO_SIZE;
    if (buffer.length > maxBytes) {
      throw new Error(`${mediaType} size exceeds limit`);
    }

    const filename = `tweet_${tweetId}_${Date.now()}_${index}.${ext}`;
    await fs.writeFile(path.join(uploadDir, filename), buffer);

    const mediaUrl = `${host}/uploads/${filename}`;
    await pool.query(
      `INSERT INTO tweet_media (tweet_id, media_type, media_url, mime_type, sort_order)
       VALUES (?, ?, ?, ?, ?)`,
      [tweetId, mediaType, mediaUrl, mimeType, index]
    );
  }
}

export async function getTweets(req, res, next) {
  try {
    const viewerHandle = req.authUser?.handle || req.query.viewerHandle?.trim() || DEFAULT_USER_HANDLE;
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
      const tweets = rows.map(mapTweet);
      return res.status(200).json(await attachMediaToTweets(tweets));
    }

    const [rows] = await pool.query(
      `${baseQuery}
       ${hasQuery ? 'WHERE t.content LIKE ?' : ''}
       ORDER BY (
         (
           t.likes * 1.5
           + t.retweets * 2.5
           + t.comments * 1.2
           + LEAST(t.views, 5000) * 0.05
         ) / POW(GREATEST(TIMESTAMPDIFF(HOUR, t.created_at, UTC_TIMESTAMP()), 1), 0.8)
         + CASE WHEN t.handle = ? THEN 1.5 ELSE 0 END
         + CASE WHEN EXISTS (
           SELECT 1
           FROM user_following uf
           WHERE uf.user_handle = ?
             AND uf.target_handle = t.handle
         ) THEN 2 ELSE 0 END
         + CASE WHEN EXISTS (
           SELECT 1
           FROM tweet_interactions ti2
           JOIN tweets tx ON tx.id = ti2.tweet_id
           WHERE ti2.user_handle = ?
             AND tx.handle = t.handle
             AND (ti2.liked = 1 OR ti2.retweeted = 1)
         ) THEN 1.5 ELSE 0 END
       ) DESC, t.created_at DESC, t.id DESC`,
      [viewerHandle, ...queryParam, viewerHandle, viewerHandle, viewerHandle]
    );
    const tweets = rows.map(mapTweet);
    return res.status(200).json(await attachMediaToTweets(tweets));
  } catch (error) {
    next(error);
  }
}

export async function getTweetById(req, res, next) {
  try {
    const viewerHandle = req.authUser?.handle || req.query.viewerHandle?.trim() || DEFAULT_USER_HANDLE;
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

    const tweet = mapTweet(rows[0]);
    const [mediaRows] = await pool.query(
      `SELECT id, media_type, media_url, mime_type, sort_order
       FROM tweet_media
       WHERE tweet_id = ?
       ORDER BY sort_order ASC, id ASC`,
      [req.params.id]
    );

    tweet.media = mapMedia(mediaRows);
    return res.status(200).json(tweet);
  } catch (error) {
    next(error);
  }
}

export async function recordTweetView(req, res, next) {
  try {
    const viewerHandle = req.authUser?.handle || req.query.viewerHandle?.trim() || DEFAULT_USER_HANDLE;
    let tweetExists = false;
    try {
      const [updateResult] = await pool.query('UPDATE tweets SET views = views + 1 WHERE id = ?', [req.params.id]);
      tweetExists = updateResult.affectedRows > 0;
    } catch (error) {
      if (error?.code !== 'ER_BAD_FIELD_ERROR') {
        throw error;
      }

      const [rows] = await pool.query('SELECT id FROM tweets WHERE id = ? LIMIT 1', [req.params.id]);
      tweetExists = rows.length > 0;
    }
    if (!tweetExists) return res.status(404).json({ message: 'Tweet not found' });

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

    const tweet = mapTweet(rows[0]);
    const [mediaRows] = await pool.query(
      `SELECT id, media_type, media_url, mime_type, sort_order
       FROM tweet_media
       WHERE tweet_id = ?
       ORDER BY sort_order ASC, id ASC`,
      [req.params.id]
    );

    tweet.media = mapMedia(mediaRows);
    return res.status(200).json(tweet);
  } catch (error) {
    next(error);
  }
}

export async function postTweet(req, res, next) {
  try {
    const { content, media = [] } = req.body;
    const normalizedContent = content?.trim() ?? '';

    if (!normalizedContent && (!Array.isArray(media) || media.length === 0)) {
      return res.status(400).json({ message: 'content or media is required' });
    }

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

    const host = `${req.protocol}://${req.get('host')}`;
    try {
      await persistTweetMedia({ tweetId: result.insertId, mediaItems: media, host });
    } catch (mediaError) {
      await pool.query('DELETE FROM tweets WHERE id = ?', [result.insertId]);
      return res.status(400).json({ message: mediaError.message || 'media upload failed' });
    }

    if (normalizedContent) {
      await upsertTopicsByContent(normalizedContent);
    }

    // detect mentions in tweet content and notify mentioned handles
    try {
      const mentions = extractMentionHandles(normalizedContent);
      for (const m of mentions) {
        pushNotificationToHandle(m, {
          title: `${normalizedAuthor} 提到了你`,
          tweetId: String(result.insertId)
        });
      }
    } catch (e) {
      // ignore mention notify errors
    }

    const [rows] = await pool.query(
      `SELECT t.*, 0 AS is_liked, 0 AS is_retweeted
       FROM tweets t
       WHERE id = ?
       LIMIT 1`,
      [result.insertId]
    );

    const tweet = mapTweet(rows[0]);
    const [mediaRows] = await pool.query(
      `SELECT id, media_type, media_url, mime_type, sort_order
       FROM tweet_media
       WHERE tweet_id = ?
       ORDER BY sort_order ASC, id ASC`,
      [result.insertId]
    );
    tweet.media = mapMedia(mediaRows);

    return res.status(201).json(tweet);
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
    // push notification to tweet owner and mentioned users
    try {
      const [tweetRows] = await pool.query('SELECT id, handle, author FROM tweets WHERE id = ? LIMIT 1', [req.params.id]);
      if (tweetRows.length > 0) {
        const tweetOwnerHandle = tweetRows[0].handle;
        // notify tweet owner
        pushNotificationToHandle(tweetOwnerHandle, {
          title: `${normalizedAuthor} 评论了你的动态`,
          tweetId: String(req.params.id),
          commentId: String(result.insertId)
        });
      }

      const mentions = extractMentionHandles(normalizedContent);
      for (const m of mentions) {
        // m already like '@someone'
        pushNotificationToHandle(m, {
          title: `${normalizedAuthor} 在评论中提到了你`,
          tweetId: String(req.params.id),
          commentId: String(result.insertId)
        });
      }
    } catch (e) {
      // ignore notification failure
    }
    return res.status(201).json(rows.map(mapComment)[0]);
  } catch (error) {
    next(error);
  }
}

export async function updateTweetInteraction(req, res, next) {
  try {
    const viewerHandle = req.authUser?.handle || DEFAULT_USER_HANDLE;
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
      [id, viewerHandle]
    );

    await pool.query(
      `UPDATE tweet_interactions
       SET ${field} = ?, updated_at = CURRENT_TIMESTAMP
       WHERE tweet_id = ? AND user_handle = ?`,
      [active ? 1 : 0, id, viewerHandle]
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
      [viewerHandle, id]
    );

    const tweet = mapTweet(rows[0]);
    const [mediaRows] = await pool.query(
      `SELECT id, media_type, media_url, mime_type, sort_order
       FROM tweet_media
       WHERE tweet_id = ?
       ORDER BY sort_order ASC, id ASC`,
      [id]
    );
    tweet.media = mapMedia(mediaRows);

    // push notification on like/retweet
    try {
      if (active === true) {
        const [tweetRows] = await pool.query('SELECT id, handle, author FROM tweets WHERE id = ? LIMIT 1', [id]);
        if (tweetRows.length > 0) {
          const tweetOwnerHandle = tweetRows[0].handle;
          const title = action === 'like' ? `${viewerHandle} 赞了你的动态` : `${viewerHandle} 转发了你的动态`;
          pushNotificationToHandle(tweetOwnerHandle, { title, tweetId: String(id) });
        }
      }
    } catch (e) {
      // ignore
    }

    return res.status(200).json(tweet);
  } catch (error) {
    next(error);
  }
}

export async function updateTweet(req, res, next) {
  try {
    const { content } = req.body;
    if (!content || !content.trim()) {
      return res.status(400).json({ message: 'content is required' });
    }

    const normalizedContent = content.trim();
    if (normalizedContent.length > 280) {
      return res.status(400).json({ message: 'content must be <= 280 chars' });
    }

    const [tweetRows] = await pool.query(
      'SELECT id, handle FROM tweets WHERE id = ? LIMIT 1',
      [req.params.id]
    );
    if (tweetRows.length === 0) {
      return res.status(404).json({ message: 'Tweet not found' });
    }

    if (tweetRows[0].handle !== req.authUser.handle) {
      return res.status(403).json({ message: 'No permission to edit this tweet' });
    }

    await pool.query('UPDATE tweets SET content = ? WHERE id = ?', [normalizedContent, req.params.id]);

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
      [req.authUser.handle, req.params.id]
    );

    return res.status(200).json(mapTweet(rows[0]));
  } catch (error) {
    next(error);
  }
}

export async function removeTweet(req, res, next) {
  try {
    const [tweetRows] = await pool.query(
      'SELECT id, handle FROM tweets WHERE id = ? LIMIT 1',
      [req.params.id]
    );
    if (tweetRows.length === 0) {
      return res.status(404).json({ message: 'Tweet not found' });
    }

    if (tweetRows[0].handle !== req.authUser.handle) {
      return res.status(403).json({ message: 'No permission to delete this tweet' });
    }

    await pool.query('DELETE FROM tweets WHERE id = ?', [req.params.id]);
    return res.status(204).send();
  } catch (error) {
    next(error);
  }
}
