import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'compose_controller.dart';

class ComposeView extends GetView<ComposeController> {
  const ComposeView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.handleCloseAttempt,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('发布动态'),
          leading: IconButton(
            onPressed: () async {
              final canLeave = await controller.handleCloseAttempt();
              if (canLeave) {
                Get.back();
              }
            },
            icon: const Icon(Icons.close),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Obx(
                () => FilledButton(
                  onPressed: controller.canSubmit ? controller.submitTweet : null,
                  child: controller.isPosting.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('发布'),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: controller.textController,
                  maxLines: null,
                  autofocus: true,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    hintText: '发生了什么新鲜事？',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Obx(() {
                final count = controller.contentLength.value;
                final exceed = count > ComposeController.maxLength;
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$count/${ComposeController.maxLength}',
                    style: TextStyle(
                      color: exceed ? Colors.redAccent : const Color(0xFF71767B),
                    ),
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
