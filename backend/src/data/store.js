import { nanoid } from 'nanoid';

const seedTweets = [
  {
    id: nanoid(),
    author: 'Halo Team',
    handle: '@halo_dev',
    content: '欢迎来到 Halo Social，这里是基于 GetX + Express 的 Twitter 风格 Demo。',
    createdAt: new Date(Date.now() - 1000 * 60 * 42).toISOString(),
    likes: 28,
    comments: 6,
    retweets: 4
  },
  {
    id: nanoid(),
    author: 'Jane Doe',
    handle: '@jane_ui',
    content: '今天把首页 Feed 的交互打磨了一下，手感很不错！',
    createdAt: new Date(Date.now() - 1000 * 60 * 11).toISOString(),
    likes: 15,
    comments: 3,
    retweets: 2
  }
];

export const db = {
  tweets: [...seedTweets]
};

export function createTweet(content, author = 'You', handle = '@you') {
  const tweet = {
    id: nanoid(),
    author,
    handle,
    content,
    createdAt: new Date().toISOString(),
    likes: 0,
    comments: 0,
    retweets: 0
  };

  db.tweets.unshift(tweet);
  return tweet;
}
