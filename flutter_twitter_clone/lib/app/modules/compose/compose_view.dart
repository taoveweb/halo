import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'compose_controller.dart';

class ComposeView extends GetView<ComposeController> {
  const ComposeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布动态'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Obx(
              () => FilledButton(
                onPressed: controller.isPosting.value
                    ? null
                    : controller.submitTweet,
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
    );
  }
}
