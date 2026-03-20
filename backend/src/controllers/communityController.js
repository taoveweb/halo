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

function mapCommunity(row) {
  return {
    id: String(row.id),
    name: row.name,
    members: row.members,
    tag: row.tag,
    joined: Boolean(row.joined)
  };
}

export async function getCommunities(_req, res, next) {
  try {
    const viewerHandle = _req.authUser?.handle || DEFAULT_USER_HANDLE;
    const [rows] = await pool.query(
      `SELECT
         c.*,
         CASE WHEN ucj.community_id IS NULL THEN 0 ELSE 1 END AS joined
       FROM communities c
       LEFT JOIN user_community_joins ucj
         ON ucj.community_id = c.id
        AND ucj.user_handle = ?
       ORDER BY c.members DESC, c.id ASC`,
      [viewerHandle]
    );

    return res.status(200).json(rows.map(mapCommunity));
  } catch (error) {
    next(error);
  }
}

export async function updateCommunityJoin(req, res, next) {
  try {
    const viewerHandle = req.authUser?.handle || DEFAULT_USER_HANDLE;
    const communityId = req.params.id;
    const active = parseBool(req.body.active);
    if (active === null) {
      return res.status(400).json({ message: 'active must be boolean' });
    }

    const [rows] = await pool.query('SELECT id FROM communities WHERE id = ? LIMIT 1', [communityId]);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Community not found' });
    }

    if (active) {
      await pool.query(
        `INSERT IGNORE INTO user_community_joins (user_handle, community_id)
         VALUES (?, ?)`,
        [viewerHandle, communityId]
      );
    } else {
      await pool.query('DELETE FROM user_community_joins WHERE user_handle = ? AND community_id = ?', [
        viewerHandle,
        communityId
      ]);
    }

    const [communityRows] = await pool.query(
      `SELECT
         c.*,
         CASE WHEN ucj.community_id IS NULL THEN 0 ELSE 1 END AS joined
       FROM communities c
       LEFT JOIN user_community_joins ucj
         ON ucj.community_id = c.id
        AND ucj.user_handle = ?
       WHERE c.id = ?
       LIMIT 1`,
      [viewerHandle, communityId]
    );

    return res.status(200).json(mapCommunity(communityRows[0]));
  } catch (error) {
    next(error);
  }
}
