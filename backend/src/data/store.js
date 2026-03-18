import { nanoid } from 'nanoid';

const seedTemplates = [
  {
    author: 'Halo Team',
    handle: '@halo_dev',
    content: '欢迎来到 Halo Social，这里是基于 GetX + Express 的 Twitter 风格 Demo。',
    likes: 28,
    comments: 6,
    retweets: 4,
    minutesAgo: 42
  },
  {
    author: 'Jane Doe',
    handle: '@jane_ui',
    content: '今天把首页 Feed 的交互打磨了一下，手感很不错！',
    likes: 15,
    comments: 3,
    retweets: 2,
    minutesAgo: 35
  },
  {
    author: 'Tom Chen',
    handle: '@dev_tom',
    content: '后端新增了 tweets/:id 接口，详情页可以直接拉取数据啦。',
    likes: 19,
    comments: 4,
    retweets: 3,
    minutesAgo: 30
  },
  {
    author: 'Amy Wu',
    handle: '@product_amy',
    content: '本周目标：把探索、社群、通知、私信页面都补齐。',
    likes: 33,
    comments: 8,
    retweets: 5,
    minutesAgo: 26
  },
  {
    author: 'Lily Sun',
    handle: '@design_lily',
    content: '深色模式下的对比度优化完成，长时间浏览更舒服。',
    likes: 24,
    comments: 5,
    retweets: 2,
    minutesAgo: 23
  },
  {
    author: 'Open Source Daily',
    handle: '@oss_daily',
    content: '今天推荐的仓库：一个结构清晰的 Flutter 全栈模板。',
    likes: 41,
    comments: 7,
    retweets: 9,
    minutesAgo: 20
  },
  {
    author: 'Flutter CN',
    handle: '@flutter_cn',
    content: 'GetX 在中小型项目里确实能提升开发效率，你们还在用什么状态管理？',
    likes: 57,
    comments: 18,
    retweets: 11,
    minutesAgo: 18
  },
  {
    author: 'Serverless Guy',
    handle: '@serverless_guy',
    content: 'Express + in-memory store 非常适合 Demo 阶段快速迭代。',
    likes: 22,
    comments: 2,
    retweets: 1,
    minutesAgo: 15
  },
  {
    author: 'Code Review Bot',
    handle: '@review_bot',
    content: 'PR #24 已通过自动检查，建议补充 2 个边界场景测试。',
    likes: 12,
    comments: 9,
    retweets: 0,
    minutesAgo: 12
  },
  {
    author: 'UI Inspiration',
    handle: '@ui_spark',
    content: '简洁的信息流 + 固定底部导航，依旧是社交产品的经典组合。',
    likes: 49,
    comments: 10,
    retweets: 8,
    minutesAgo: 9
  },
  {
    author: 'Growth Hacker',
    handle: '@growth_hacker',
    content: '新用户首日留存，关键在于让他在 3 分钟内看到足够多内容。',
    likes: 31,
    comments: 6,
    retweets: 6,
    minutesAgo: 6
  },
  {
    author: 'You',
    handle: '@you',
    content: '刚刚完成“其它页面一起生成 + 多数据”需求，继续冲！',
    likes: 5,
    comments: 1,
    retweets: 0,
    minutesAgo: 3
  }
];

const seedTweets = seedTemplates.map((template) => ({
  id: nanoid(),
  author: template.author,
  handle: template.handle,
  content: template.content,
  createdAt: new Date(Date.now() - 1000 * 60 * template.minutesAgo).toISOString(),
  likes: template.likes,
  comments: template.comments,
  retweets: template.retweets
}));

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
