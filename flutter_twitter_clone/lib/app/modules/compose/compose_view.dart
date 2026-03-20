import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                      children: const [
                        _BottomActionIcon(Icons.photo_outlined),
                        _BottomActionIcon(Icons.gif_box_outlined),
                        _BottomActionIcon(Icons.sync_alt),
                        _BottomActionIcon(Icons.format_list_bulleted),
                        _BottomActionIcon(Icons.access_time),
                        _BottomActionIcon(Icons.location_on_outlined),
                        _BottomActionIcon(Icons.flag_outlined),
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
  const _BottomActionIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Icon(icon, color: ComposeView._twitterBlue, size: 24),
    );
  }
}
