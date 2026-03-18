import { createTweet, db } from '../data/store.js';

export function getTweets(req, res) {
  res.status(200).json(db.tweets);
}

export function getTweetById(req, res) {
  const tweet = db.tweets.find((item) => item.id === req.params.id);
  if (!tweet) {
    return res.status(404).json({ message: 'Tweet not found' });
  }

  return res.status(200).json(tweet);
}

export function postTweet(req, res) {
  const { content, author, handle } = req.body;
  if (!content || !content.trim()) {
    return res.status(400).json({ message: 'content is required' });
  }

  if (content.length > 280) {
    return res.status(400).json({ message: 'content must be <= 280 chars' });
  }

  const tweet = createTweet(content.trim(), author, handle);
  return res.status(201).json(tweet);
}
