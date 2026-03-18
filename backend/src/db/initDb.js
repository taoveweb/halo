import { pool } from './mysql.js';
import { seedTemplates } from '../data/seedData.js';

export async function initDb() {
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
