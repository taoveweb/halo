import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/comment_model.dart';
import '../../widgets/tweet_card.dart';
import 'tweet_detail_controller.dart';

class TweetDetailView extends GetView<TweetDetailController> {
  const TweetDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: controller.hasNewComment.value);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('动态详情'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(result: controller.hasNewComment.value),
          ),
        ),
        body: Obx(() {
        final tweet = controller.tweet.value;
        if (tweet == null) {
          return const Center(child: Text('暂无内容'));
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadComments,
                child: ListView(
                  children: [
                    TweetCard(tweet: tweet),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        '评论',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (controller.isLoading.value)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (controller.error.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          controller.error.value,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      )
                    else if (controller.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('还没有评论，来抢沙发吧。', style: TextStyle(color: Color(0xFF71767B))),
                      )
                    else
                      ...controller.comments.map((item) => _CommentTile(comment: item)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF2F3336), width: 0.4)),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.commentInputController,
                        maxLength: 280,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: '写下你的评论...',
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      return FilledButton(
                        onPressed: controller.isPosting.value ? null : controller.postComment,
                        child: controller.isPosting.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('发送'),
                      );
                    }),
                  ],
                ),
              ),
            )
          ],
        );
      }),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2F3336), width: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${comment.author} ${comment.handle} · ${DateFormat('MM-dd HH:mm').format(comment.createdAt)}',
            style: const TextStyle(color: Color(0xFF71767B), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(comment.content, style: const TextStyle(color: Colors.white, height: 1.35)),
        ],
      ),
    );
  }
}
