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

const seedFollowing = ['@halo_dev', '@jane_ui', '@dev_tom', '@flutter_cn'];

export async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      email VARCHAR(120) NOT NULL,
      password_hash VARCHAR(255) NOT NULL,
      name VARCHAR(80) NOT NULL,
      handle VARCHAR(80) NOT NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uk_users_email (email),
      UNIQUE KEY uk_users_handle (handle)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);

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

  await pool.query(
    `INSERT INTO users (email, password_hash, name, handle)
     VALUES (?, ?, ?, ?)
     ON DUPLICATE KEY UPDATE email = email`,
    ['halo@example.com', hashPassword('123456'), 'Halo User', '@halo_user']
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

  for (const handle of seedFollowing) {
    await pool.query(
      `INSERT IGNORE INTO user_following (user_handle, target_handle)
       VALUES ('@you', ?)`,
      [handle]
    );
  }
}
