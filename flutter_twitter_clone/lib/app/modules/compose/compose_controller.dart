import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/tweet_service.dart';

class ComposeController extends GetxController {
  ComposeController(this._tweetService);

  static const int maxLength = 280;
  static const String _draftStorageKey = 'compose_draft_content';

  final TweetService _tweetService;
  final TextEditingController textController = TextEditingController();
  final RxBool isPosting = false.obs;
  final RxInt contentLength = 0.obs;

  bool get canSubmit {
    final length = contentLength.value;
    return !isPosting.value && length > 0 && length <= maxLength;
  }

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_handleTextChanged);
    _restoreDraft();
  }

  void _handleTextChanged() {
    contentLength.value = textController.text.trim().length;
  }

  Future<bool> handleCloseAttempt() async {
    if (isPosting.value || textController.text.trim().isEmpty) {
      return true;
    }

    final shouldLeave = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('放弃本次编辑？'),
            content: const Text('你还有未发布的内容，确认返回吗？'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('继续编辑'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('放弃'),
              ),
            ],
          ),
        ) ??
        false;
    return shouldLeave;
  }

  Future<void> saveDraft() async {
    final draft = textController.text.trim();
    final prefs = await SharedPreferences.getInstance();

    if (draft.isEmpty) {
      await prefs.remove(_draftStorageKey);
      Get.snackbar('草稿', '内容为空，已清空草稿');
      return;
    }

    await prefs.setString(_draftStorageKey, draft);
    Get.snackbar('草稿', '已保存到草稿箱');
  }

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString(_draftStorageKey)?.trim();

    if (draft == null || draft.isEmpty) {
      return;
    }

    textController.text = draft;
    textController.selection = TextSelection.collapsed(offset: draft.length);
    _handleTextChanged();
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftStorageKey);
  }

  Future<void> submitTweet() async {
    final content = textController.text.trim();
    if (content.isEmpty) {
      Get.snackbar('提示', '请输入内容后再发布');
      return;
    }

    if (content.length > maxLength) {
      Get.snackbar('提示', '内容不能超过 $maxLength 字');
      return;
    }

    try {
      isPosting.value = true;
      await _tweetService.createTweet(content);
      await _clearDraft();
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
    textController
      ..removeListener(_handleTextChanged)
      ..dispose();
    super.onClose();
  }
}
