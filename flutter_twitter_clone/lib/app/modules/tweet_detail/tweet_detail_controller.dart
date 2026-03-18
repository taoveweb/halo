import 'package:flutter/material.dart';
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

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TweetModel) {
      tweet.value = args;
      loadComments();
    }
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
    commentInputController.dispose();
    super.onClose();
  }
}
