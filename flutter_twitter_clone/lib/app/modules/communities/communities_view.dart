import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';
import '../social/social_controller.dart';

class CommunitiesView extends GetView<SocialController> {
  const CommunitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final scrollController = ScrollController();

    void sendPrompt() {
      final prompt = textController.text.trim();
      if (prompt.isEmpty) return;
      controller.askAi(prompt);
      textController.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent + 120,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Halo AI', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    const Text(
                      '近期对话',
                      style: TextStyle(color: Color(0xFF8B98A5), fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _QuickPrompt(
                          text: 'AI失业与消费循环危机',
                          onTap: () => controller.askAi('聊聊 AI 失业与消费循环危机。'),
                        ),
                        _QuickPrompt(
                          text: 'Keyboard Smash Moment',
                          onTap: () => controller.askAi('写一段关于 Keyboard Smash Moment 的幽默短文。'),
                        ),
                        _QuickPrompt(
                          text: 'Vue 3 前端面试题总结',
                          onTap: () => controller.askAi('总结一份 Vue 3 前端面试题，分基础和进阶。'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...controller.aiMessages.map(
                      (msg) => Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: msg.isUser ? const Color(0xFF1D9BF0) : const Color(0xFF16181C),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF2F3336)),
                          ),
                          child: Text(
                            msg.text,
                            style: const TextStyle(color: Colors.white, height: 1.4),
                          ),
                        ),
                      ),
                    ),
                    if (controller.aiSending.value)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    if (controller.aiError.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          controller.aiError.value!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                  ],
                );
              }),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(top: BorderSide(color: Color(0xFF2F3336))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => sendPrompt(),
                      decoration: InputDecoration(
                        hintText: '随便问点什么',
                        hintStyle: const TextStyle(color: Color(0xFF71767B)),
                        filled: true,
                        fillColor: const Color(0xFF121A2A),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(() {
                    return IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: controller.aiSending.value
                            ? const Color(0xFF2F3336)
                            : const Color(0xFF1D9BF0),
                      ),
                      onPressed: controller.aiSending.value ? null : sendPrompt,
                      icon: const Icon(Icons.graphic_eq, color: Colors.white),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPrompt extends StatelessWidget {
  const _QuickPrompt({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF121A2A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2F3336)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFFE7E9EA), fontSize: 15),
        ),
      ),
    );
  }
}
