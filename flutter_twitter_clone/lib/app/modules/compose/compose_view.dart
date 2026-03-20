import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'compose_controller.dart';

class ComposeView extends GetView<ComposeController> {
  const ComposeView({super.key});

  static const Color _twitterBlue = Color(0xFF1D9BF0);
  static const Color _mutedText = Color(0xFF71767B);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.handleCloseAttempt,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              final canLeave = await controller.handleCloseAttempt();
              if (canLeave) {
                Get.back();
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          titleSpacing: 0,
          title: TextButton(
            onPressed: controller.saveDraft,
            child: const Text(
              '草稿',
              style: TextStyle(
                color: _twitterBlue,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Obx(
                () => FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(92, 40),
                    backgroundColor: controller.canSubmit ? _twitterBlue : const Color(0xFF0F4268),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: controller.canSubmit ? controller.submitTweet : null,
                  child: controller.isPosting.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          '发帖',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: Color(0xFF32414A),
                          child: Icon(Icons.person, color: Color(0xFF9AA7B1), size: 34),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: controller.textController,
                            maxLines: null,
                            autofocus: true,
                            style: const TextStyle(fontSize: 38 / 2, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: '有什么新鲜事？',
                              hintStyle: TextStyle(color: _mutedText, fontSize: 38 / 2),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => controller.mediaItems.isEmpty
                          ? const SizedBox.shrink()
                          : SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.mediaItems.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (_, index) {
                                  final item = controller.mediaItems[index];
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          width: 160,
                                          child: item.isVideo
                                              ? _LocalVideoPreview(path: item.path)
                                              : Image.file(File(item.path), fit: BoxFit.cover),
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () => controller.removeMediaAt(index),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black87,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Get.snackbar('权限', '当前为所有人可以回复'),
                        borderRadius: BorderRadius.circular(18),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.public, size: 18, color: _twitterBlue),
                              SizedBox(width: 8),
                              Text(
                                '所有人可以回复',
                                style: TextStyle(
                                  color: _twitterBlue,
                                  fontSize: 30 / 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFF2F3336), thickness: 1),
                    Row(
                      children: [
                        _BottomActionIcon(icon: Icons.photo_outlined, onTap: controller.pickImage),
                        _BottomActionIcon(icon: Icons.videocam_outlined, onTap: controller.pickVideo),
                        const _BottomActionIcon(icon: Icons.gif_box_outlined),
                        const _BottomActionIcon(icon: Icons.sync_alt),
                        const _BottomActionIcon(icon: Icons.format_list_bulleted),
                        const _BottomActionIcon(icon: Icons.access_time),
                        const _BottomActionIcon(icon: Icons.location_on_outlined),
                      ],
                    ),
                  ],
                ),
              ),
              Obx(() {
                final count = controller.contentLength.value;
                final exceed = count > ComposeController.maxLength;
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$count/${ComposeController.maxLength}',
                    style: TextStyle(color: exceed ? Colors.redAccent : _mutedText),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActionIcon extends StatelessWidget {
  const _BottomActionIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Icon(icon, color: ComposeView._twitterBlue, size: 24),
      ),
    );
  }
}

class _LocalVideoPreview extends StatefulWidget {
  const _LocalVideoPreview({required this.path});

  final String path;

  @override
  State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.file(File(widget.path));
    _videoController = controller;
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
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: const Color(0xFF1E1E1E),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }
}
