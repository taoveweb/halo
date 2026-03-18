import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/tweet_service.dart';

class ComposeController extends GetxController {
  ComposeController(this._tweetService);

  final TweetService _tweetService;
  final TextEditingController textController = TextEditingController();
  final RxBool isPosting = false.obs;

  Future<void> submitTweet() async {
    final content = textController.text.trim();
    if (content.isEmpty) {
      Get.snackbar('提示', '请输入内容后再发布');
      return;
    }

    try {
      isPosting.value = true;
      await _tweetService.createTweet(content);
      Get.back(result: true);
      Get.snackbar('成功', '动态已发布');
      textController.clear();
    } catch (e) {
      Get.snackbar('发布失败', e.toString());
    } finally {
      isPosting.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
