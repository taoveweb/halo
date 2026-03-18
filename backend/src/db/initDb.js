import { pool } from './mysql.js';
import { seedTemplates } from '../data/seedData.js';
import { hashPassword } from '../utils/password.js';

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
