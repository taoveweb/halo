import { pool } from './mysql.js';
import { seedTemplates } from '../data/seedData.js';
import { hashPassword } from '../utils/password.js';

const seedTopics = [
  { title: '#Flutter', posts: 12000 },
  { title: '#GetX', posts: 4362 },
  { title: '#HaloSocial', posts: 2993 },
  { title: '#AIProductivity', posts: 8501 },
  { title: '#OpenSource', posts: 6218 },
  { title: '#NodeJS', posts: 3887 }
];

const seedCommunities = [
  { name: 'Flutter 中文社区', members: 12400, tag: '移动开发' },
  { name: '前端工程师联盟', members: 9100, tag: 'Web' },
  { name: '独立开发者日记', members: 7500, tag: '创业' },
  { name: '产品增长实验室', members: 5300, tag: '增长' },
  { name: '设计系统研究所', members: 4600, tag: '设计' }
];

const seedFollowing = ['@halo_dev', '@jane_ui', '@dev_tom', '@flutter_cn'];

export async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      email VARCHAR(120) NOT NULL,
      password_hash VARCHAR(255) NOT NULL,
      name VARCHAR(80) NOT NULL,
      handle VARCHAR(80) NOT NULL,
      avatar_url VARCHAR(255) NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uk_users_email (email),
      UNIQUE KEY uk_users_handle (handle)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  // Older MySQL versions do not support `ADD COLUMN IF NOT EXISTS`.
  // Check information_schema and add the column only when it's missing.
  const [colRows] = await pool.query(
    `SELECT COUNT(*) AS count FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ?`,
    [process.env.MYSQL_DATABASE, 'users', 'avatar_url']
  );

  if (colRows[0].count === 0) {
    await pool.query(`ALTER TABLE users ADD COLUMN avatar_url VARCHAR(255) NULL AFTER handle`);
  }

  await pool.query(`
    CREATE TABLE IF NOT EXISTS auth_tokens (
      token CHAR(64) NOT NULL,
      user_id BIGINT UNSIGNED NOT NULL,
      expires_at DATETIME NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (token),
      KEY idx_auth_tokens_user (user_id),
      KEY idx_auth_tokens_expires (expires_at),
      CONSTRAINT fk_auth_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS tweets (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      author VARCHAR(80) NOT NULL,
      handle VARCHAR(80) NOT NULL,
      content VARCHAR(280) NOT NULL,
      likes INT NOT NULL DEFAULT 0,
      comments INT NOT NULL DEFAULT 0,
      retweets INT NOT NULL DEFAULT 0,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);


  await pool.query(`
    CREATE TABLE IF NOT EXISTS tweet_media (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      tweet_id BIGINT UNSIGNED NOT NULL,
      media_type ENUM('image', 'video') NOT NULL,
      media_url VARCHAR(255) NOT NULL,
      mime_type VARCHAR(80) NOT NULL,
      sort_order INT NOT NULL DEFAULT 0,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      KEY idx_tweet_media_tweet (tweet_id),
      CONSTRAINT fk_tweet_media_tweet FOREIGN KEY (tweet_id) REFERENCES tweets(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
  await pool.query(`
    CREATE TABLE IF NOT EXISTS comments (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      tweet_id BIGINT UNSIGNED NOT NULL,
      author VARCHAR(80) NOT NULL,
      handle VARCHAR(80) NOT NULL,
      content VARCHAR(280) NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      CONSTRAINT fk_comments_tweet FOREIGN KEY (tweet_id) REFERENCES tweets(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS admin_audit_logs (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      operator VARCHAR(80) NOT NULL,
      action VARCHAR(40) NOT NULL,
      target_type VARCHAR(40) NOT NULL,
      target_id VARCHAR(80) NULL,
      detail VARCHAR(255) NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      KEY idx_admin_audit_logs_created_at (created_at),
      KEY idx_admin_audit_logs_action (action)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(
    `INSERT INTO users (email, password_hash, name, handle, avatar_url)
     VALUES (?, ?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE email = email`,
    ['halo@example.com', hashPassword('123456'), 'Halo User', '@halo_user', null]
  );

  const [existing] = await pool.query('SELECT COUNT(*) AS count FROM tweets');
  if (existing[0].count > 0) {
    return;
  }

  await pool.query(`
    CREATE TABLE IF NOT EXISTS topics (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      title VARCHAR(80) NOT NULL,
      posts INT NOT NULL DEFAULT 0,
      PRIMARY KEY (id),
      UNIQUE KEY uk_topics_title (title)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS user_topic_follows (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      user_handle VARCHAR(80) NOT NULL,
      topic_id BIGINT UNSIGNED NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uk_user_topic (user_handle, topic_id),
      CONSTRAINT fk_user_topic_topic FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS user_following (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      user_handle VARCHAR(80) NOT NULL,
      target_handle VARCHAR(80) NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uk_user_following (user_handle, target_handle)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS communities (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      name VARCHAR(120) NOT NULL,
      members INT NOT NULL DEFAULT 0,
      tag VARCHAR(80) NOT NULL,
      PRIMARY KEY (id),
      UNIQUE KEY uk_communities_name (name)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS user_community_joins (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      user_handle VARCHAR(80) NOT NULL,
      community_id BIGINT UNSIGNED NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uk_user_community (user_handle, community_id),
      CONSTRAINT fk_user_community_community FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

  const [existingTweets] = await pool.query('SELECT COUNT(*) AS count FROM tweets');
  if (existingTweets[0].count === 0) {
    for (const template of seedTemplates) {
      const createdAt = new Date(Date.now() - 1000 * 60 * template.minutesAgo);

      const [tweetResult] = await pool.query(
        `INSERT INTO tweets (author, handle, content, likes, comments, retweets, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          template.author,
          template.handle,
          template.content,
          template.likes,
          template.commentTemplates.length,
          template.retweets,
          createdAt
        ]
      );

      for (const comment of template.commentTemplates) {
        const commentTime = new Date(Date.now() - 1000 * 60 * comment.minutesAgo);
        await pool.query(
          `INSERT INTO comments (tweet_id, author, handle, content, created_at)
           VALUES (?, ?, ?, ?, ?)`,
          [tweetResult.insertId, comment.author, comment.handle, comment.content, commentTime]
        );
      }
    }
  }

  for (const topic of seedTopics) {
    await pool.query(
      `INSERT INTO topics (title, posts)
       VALUES (?, ?)
       ON DUPLICATE KEY UPDATE posts = VALUES(posts)`,
      [topic.title, topic.posts]
    );
  }

  for (const community of seedCommunities) {
    await pool.query(
      `INSERT INTO communities (name, members, tag)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE members = VALUES(members), tag = VALUES(tag)`,
      [community.name, community.members, community.tag]
    );
  }

  for (const handle of seedFollowing) {
    await pool.query(
      `INSERT IGNORE INTO user_following (user_handle, target_handle)
       VALUES ('@you', ?)`,
      [handle]
    );
  }
}
