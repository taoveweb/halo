import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/chat_model.dart';
import '../social/social_controller.dart';

class MessageDetailView extends StatefulWidget {
  const MessageDetailView({super.key});

  @override
  State<MessageDetailView> createState() => _MessageDetailViewState();
}

class _MessageDetailViewState extends State<MessageDetailView> {
  final SocialController controller = Get.find<SocialController>();
  final TextEditingController inputController = TextEditingController();

  ChatModel get chat => (Get.arguments as Map<String, dynamic>)['chat'] as ChatModel;

  @override
  void initState() {
    super.initState();
    controller.loadChatDetail(chat.id);
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = inputController.text;
    if (text.trim().isEmpty) return;
    inputController.clear();
    await controller.sendMessage(chat.id, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: chat.avatar.isNotEmpty ? NetworkImage(chat.avatar) : null,
              child: chat.avatar.isEmpty ? Text(chat.name.isEmpty ? '?' : chat.name[0]) : null,
            ),
            const SizedBox(width: 12),
            Text(chat.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: Obx(() {
        final detail = controller.activeChatDetail.value;
        if (controller.chatDetailLoading.value && detail == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (detail == null) {
          return const Center(child: Text('会话不存在', style: TextStyle(color: Colors.white70)));
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 48, backgroundImage: NetworkImage(detail.avatar)),
                        const SizedBox(height: 14),
                        Text(detail.name, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700)),
                        Text(detail.handle, style: const TextStyle(color: Color(0xFF71767B), fontSize: 20)),
                        Text('Joined ${detail.joinedAt}', style: const TextStyle(color: Color(0xFF71767B), fontSize: 14)),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                          child: const Text('View Profile'),
                        ),
                        const SizedBox(height: 40),
                        Text(detail.createdDate, style: const TextStyle(color: Color(0xFF71767B), fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...detail.messages.map((msg) => Align(
                        alignment: msg.isOutbound ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2732),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                              const SizedBox(width: 8),
                              Text(msg.time, style: const TextStyle(color: Color(0xFFAAB8C2), fontSize: 12)),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF2F3336)))),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: Color(0xFF1E2732), shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: inputController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Unencrypted message',
                          hintStyle: const TextStyle(color: Color(0xFF71767B)),
                          filled: true,
                          fillColor: const Color(0xFF1E2732),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    IconButton(onPressed: _send, icon: const Icon(Icons.send, color: Colors.white)),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
