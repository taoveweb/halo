import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/tweet_model.dart';

class TweetCard extends StatelessWidget {
  const TweetCard({
    super.key,
    required this.tweet,
    this.onTap,
  });

  final TweetModel tweet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF2F3336), width: 0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF1D9BF0),
              child: Text(tweet.author.characters.first),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tweet.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${tweet.handle} · ${DateFormat('MM-dd HH:mm').format(tweet.createdAt)}',
                        style: const TextStyle(color: Color(0xFF71767B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tweet.content,
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatItem(icon: Icons.chat_bubble_outline, value: tweet.comments),
                      _StatItem(icon: Icons.repeat, value: tweet.retweets),
                      _StatItem(icon: Icons.favorite_border, value: tweet.likes),
                      const Icon(Icons.share_outlined, color: Color(0xFF71767B), size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF71767B), size: 18),
        const SizedBox(width: 4),
        Text('$value', style: const TextStyle(color: Color(0xFF71767B))),
      ],
    );
  }
}
