import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/tweet_model.dart';

class TweetCard extends StatelessWidget {
  const TweetCard({
    super.key,
    required this.tweet,
    this.onTap,
    this.onComment,
    this.onLike,
    this.onRetweet,
    this.onShare,
  });

  final TweetModel tweet;
  final VoidCallback? onTap;
  final VoidCallback? onComment;
  final VoidCallback? onLike;
  final VoidCallback? onRetweet;
  final VoidCallback? onShare;

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
                      _StatItem(
                        icon: Icons.chat_bubble_outline,
                        value: tweet.comments,
                        onTap: onComment,
                      ),
                      _StatItem(
                        icon: tweet.isRetweeted ? Icons.repeat_on : Icons.repeat,
                        value: tweet.retweets,
                        color: tweet.isRetweeted ? const Color(0xFF00BA7C) : null,
                        onTap: onRetweet,
                      ),
                      _StatItem(
                        icon: tweet.isLiked ? Icons.favorite : Icons.favorite_border,
                        value: tweet.likes,
                        color: tweet.isLiked ? const Color(0xFFF91880) : null,
                        onTap: onLike,
                      ),
                      _StatItem(icon: Icons.share_outlined, value: null, onTap: onShare),
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
  const _StatItem({
    required this.icon,
    required this.value,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final int? value;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? const Color(0xFF71767B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 18),
            if (value != null) ...[
              const SizedBox(width: 4),
              Text('$value', style: TextStyle(color: itemColor)),
            ],
          ],
        ),
      ),
    );
  }
}
