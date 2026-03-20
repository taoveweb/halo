import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/tweet_service.dart';

class ComposeMediaItem {
  ComposeMediaItem({
    required this.path,
    required this.mediaType,
    required this.mimeType,
    required this.dataUrl,
  });

  final String path;
  final String mediaType;
  final String mimeType;
  final String dataUrl;

  bool get isVideo => mediaType == 'video';
}

class ComposeController extends GetxController {
  ComposeController(this._tweetService);

  static const int maxLength = 280;
  static const int maxMediaCount = 4;

  final TweetService _tweetService;
  final TextEditingController textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final RxBool isPosting = false.obs;
  final RxInt contentLength = 0.obs;
  final RxList<ComposeMediaItem> mediaItems = <ComposeMediaItem>[].obs;

  bool get canSubmit {
    final length = contentLength.value;
    final hasContent = length > 0;
    final hasMedia = mediaItems.isNotEmpty;
    return !isPosting.value && (hasContent || hasMedia) && length <= maxLength;
  }

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    contentLength.value = textController.text.trim().length;
  }

  Future<bool> handleCloseAttempt() async {
    if (isPosting.value || (textController.text.trim().isEmpty && mediaItems.isEmpty)) {
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

  void saveDraft() {
    Get.snackbar('草稿', '已保存到草稿箱');
  }

  Future<void> pickImage() async {
    if (mediaItems.length >= maxMediaCount) {
      Get.snackbar('提示', '最多上传 $maxMediaCount 个媒体文件');
      return;
    }
    final file = await _picker.pickImage(imageQuality: 85);
    if (file == null) return;
    await _appendMedia(file, 'image');
  }

  Future<void> pickVideo() async {
    if (mediaItems.length >= maxMediaCount) {
      Get.snackbar('提示', '最多上传 $maxMediaCount 个媒体文件');
      return;
    }
    final file = await _picker.pickVideo(maxDuration: const Duration(seconds: 60));
    if (file == null) return;
    await _appendMedia(file, 'video');
  }

  void removeMediaAt(int index) {
    if (index < 0 || index >= mediaItems.length) return;
    mediaItems.removeAt(index);
  }

  Future<void> _appendMedia(XFile file, String mediaType) async {
    try {
      final bytes = await file.readAsBytes();
      final mimeType = _guessMimeType(file.path, mediaType);
      final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
      mediaItems.add(
        ComposeMediaItem(
          path: file.path,
          mediaType: mediaType,
          mimeType: mimeType,
          dataUrl: dataUrl,
        ),
      );
    } catch (e) {
      Get.snackbar('媒体处理失败', e.toString());
    }
  }

  String _guessMimeType(String path, String mediaType) {
    final lower = path.toLowerCase();
    if (mediaType == 'image') {
      if (lower.endsWith('.png')) return 'image/png';
      if (lower.endsWith('.webp')) return 'image/webp';
      if (lower.endsWith('.gif')) return 'image/gif';
      return 'image/jpeg';
    }
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.webm')) return 'video/webm';
    return 'video/mp4';
  }

  Future<void> submitTweet() async {
    final content = textController.text.trim();

    if (content.isEmpty && mediaItems.isEmpty) {
      Get.snackbar('提示', '请输入内容或添加媒体后再发布');
      return;
    }

    if (content.length > maxLength) {
      Get.snackbar('提示', '内容不能超过 $maxLength 字');
      return;
    }

    try {
      isPosting.value = true;
      final mediaPayload = mediaItems
          .map(
            (item) => {
              'mediaBase64': item.dataUrl,
            },
          )
          .toList();
      await _tweetService.createTweet(content, media: mediaPayload);
      Get.back(result: true);
      Get.snackbar('成功', '动态已发布');
      textController.clear();
      mediaItems.clear();
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
