import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/models/comment_model.dart';
import '../../data/models/tweet_model.dart';
import '../../data/services/tweet_service.dart';
import '../social/social_controller.dart';
import 'package:flutter/widgets.dart';

class TweetDetailController extends GetxController {
  TweetDetailController(this._tweetService);

  final TweetService _tweetService;

  final Rxn<TweetModel> tweet = Rxn<TweetModel>();
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final Map<String, GlobalKey> commentKeys = {};
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
      _refreshTweet();
      _recordView();
      loadComments();
    } else if (args is Map) {
      final t = args['tweet'];
      if (t is TweetModel) {
        tweet.value = t;
        _refreshTweet();
        _recordView();
        _initialJumpCommentId = args['commentId']?.toString();
        loadComments();
      }
    }
    commentInputController.addListener(_handleCommentInputChanged);
  }

  String? _initialJumpCommentId;

  Future<void> _recordView() async {
    final current = tweet.value;
    if (current == null) return;
    try {
      final updated = await _tweetService.recordTweetView(current.id);
      tweet.value = updated;
      if (updated.views != current.views) {
        hasNewComment.value = true;
      }
    } catch (_) {
      // 记录浏览失败不影响用户体验
    }
  }

  Future<void> _refreshTweet() async {
    final current = tweet.value;
    if (current == null) return;
    try {
      final latest = await _tweetService.fetchTweetById(current.id);
      tweet.value = latest;
    } catch (_) {}
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
      if (_initialJumpCommentId != null && _initialJumpCommentId!.isNotEmpty) {
        final id = _initialJumpCommentId!;
        // delay to wait widget build
        Future.delayed(const Duration(milliseconds: 120), () => scrollToComment(id));
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void scrollToComment(String commentId) {
    final key = commentKeys[commentId];
    if (key == null) return;
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.1);
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
      // refresh notifications immediately so recipient (including self) sees it
      try {
        if (Get.isRegistered<SocialController>()) {
          final social = Get.find<SocialController>();
          await social.loadNotifications();
        }
      } catch (_) {
        // ignore
      }
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
