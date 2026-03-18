import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/tweet_card.dart';
import 'tweet_detail_controller.dart';

class TweetDetailView extends GetView<TweetDetailController> {
  const TweetDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动态详情')),
      body: Obx(() {
        final tweet = controller.tweet.value;
        if (tweet == null) {
          return const Center(child: Text('暂无内容'));
        }

        return ListView(
          children: [
            TweetCard(tweet: tweet),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '评论功能可接入后端 /api/tweets/:id/comments 接口进行拓展。',
                style: TextStyle(color: Color(0xFF71767B)),
              ),
            ),
          ],
        );
      }),
    );
  }
}
