import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

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
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
              backgroundImage: tweet.avatarUrl != null ? NetworkImage(tweet.avatarUrl!) : null,
              child: tweet.avatarUrl == null ? Text(tweet.author.characters.first) : null,
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
                      Expanded(
                        child: Text(
                          '${tweet.handle} · ${DateFormat('MM-dd HH:mm').format(tweet.createdAt)}',
                          style: const TextStyle(color: Color(0xFF71767B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (tweet.content.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      tweet.content,
                      style: const TextStyle(color: Colors.white, height: 1.4),
                    ),
                  ],
                  if (tweet.media.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _TweetMediaGrid(media: tweet.media),
                  ],
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
                      _StatItem(icon: Icons.bookmark_border, value: null, onTap: onShare),
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

class _TweetMediaGrid extends StatelessWidget {
  const _TweetMediaGrid({required this.media});

  final List<TweetMediaModel> media;

  @override
  Widget build(BuildContext context) {
    final visibleMedia = media.take(4).toList();
    if (visibleMedia.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 220,
          width: double.infinity,
          child: _TweetMediaItem(media: visibleMedia.first),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: visibleMedia.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (_, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _TweetMediaItem(media: visibleMedia[index]),
        );
      },
    );
  }
}

class _TweetMediaItem extends StatelessWidget {
  const _TweetMediaItem({required this.media});

  final TweetMediaModel media;

  @override
  Widget build(BuildContext context) {
    if (media.isVideo) {
      return _AutoPlayVideo(url: media.mediaUrl);
    }
    return Image.network(media.mediaUrl, fit: BoxFit.cover);
  }
}

class _AutoPlayVideo extends StatefulWidget {
  const _AutoPlayVideo({required this.url});

  final String url;

  @override
  State<_AutoPlayVideo> createState() => _AutoPlayVideoState();
}

class _AutoPlayVideoState extends State<_AutoPlayVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    controller
      ..setVolume(0)
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: const Color(0xFF1E1E1E),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
        const Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.volume_off, color: Colors.white70, size: 16),
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
