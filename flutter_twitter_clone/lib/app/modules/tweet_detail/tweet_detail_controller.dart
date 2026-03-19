import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/models/comment_model.dart';
import '../../data/models/tweet_model.dart';
import '../../data/services/tweet_service.dart';

class TweetDetailController extends GetxController {
  TweetDetailController(this._tweetService);

  final TweetService _tweetService;

  final Rxn<TweetModel> tweet = Rxn<TweetModel>();
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final TextEditingController commentInputController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;
  final RxBool hasNewComment = false.obs;
  final RxString error = ''.obs;
  final RxInt commentLength = 0.obs;

  bool get canSendComment => !isPosting.value && commentLength.value > 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TweetModel) {
      tweet.value = args;
      loadComments();
    }
    commentInputController.addListener(_handleCommentInputChanged);
  }

  void _handleCommentInputChanged() {
    commentLength.value = commentInputController.text.trim().length;
  }

  Future<void> loadComments() async {
    final current = tweet.value;
    if (current == null) return;

    try {
      isLoading.value = true;
      error.value = '';
      final result = await _tweetService.fetchComments(current.id);
      comments.assignAll(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike() async {
    final current = tweet.value;
    if (current == null) return;

    final updated = await _tweetService.likeTweet(tweetId: current.id, active: !current.isLiked);
    tweet.value = updated;
    hasNewComment.value = true;
  }

  Future<void> toggleRetweet() async {
    final current = tweet.value;
    if (current == null) return;

    final updated = await _tweetService.retweetTweet(tweetId: current.id, active: !current.isRetweeted);
    tweet.value = updated;
    hasNewComment.value = true;
  }

  Future<void> shareTweet() async {
    final current = tweet.value;
    if (current == null) return;

    final text = '${current.author} ${current.handle}\n${current.content}';
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar('已复制', '动态内容已复制到剪贴板', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> postComment() async {
    final current = tweet.value;
    if (current == null || isPosting.value) return;

    final content = commentInputController.text.trim();
    if (content.isEmpty) return;

    try {
      isPosting.value = true;
      final created = await _tweetService.createComment(tweetId: current.id, content: content);
      comments.add(created);
      commentInputController.clear();
      hasNewComment.value = true;
      tweet.value = current.copyWith(comments: current.comments + 1);
    } catch (e) {
      Get.snackbar('评论失败', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isPosting.value = false;
    }
  }

  @override
  void onClose() {
    commentInputController
      ..removeListener(_handleCommentInputChanged)
      ..dispose();
    super.onClose();
  }
}
