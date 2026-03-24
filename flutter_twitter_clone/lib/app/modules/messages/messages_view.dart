import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_bottom_nav.dart';
import '../social/social_controller.dart';

class MessagesView extends GetView<SocialController> {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            onRefresh: controller.refreshAll,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              children: [
                Row(
                  children: const [
                    CircleAvatar(radius: 18, child: Icon(Icons.person, size: 24)),
                    SizedBox(width: 10),
                    Text('Chat', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Spacer(),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 52,
                  decoration: BoxDecoration(color: const Color(0xFF121A2A), borderRadius: BorderRadius.circular(28)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Color(0xFF71767B), size: 28),
                      SizedBox(width: 12),
                      Text('Search', style: TextStyle(color: Color(0xFF71767B), fontSize: 20)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...controller.chats.map((item) => InkWell(
                      onTap: () => controller.openChatDetail(item),
                      onLongPress: () => controller.togglePinChat(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF2F3336))),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: item.avatar.isNotEmpty ? NetworkImage(item.avatar) : null,
                              child: item.avatar.isEmpty
                                  ? Text(item.name.isEmpty ? '?' : item.name[0])
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(item.name,
                                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                      ),
                                      Text(item.time,
                                          style: const TextStyle(color: Color(0xFF71767B), fontSize: 18)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text('You: ', style: TextStyle(color: Color(0xFF71767B), fontSize: 16)),
                                      Expanded(
                                        child: Text(
                                          item.message,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Color(0xFF71767B), fontSize: 16),
                                        ),
                                      ),
                                      if (item.unreadCount > 0)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1D9BF0),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text('${item.unreadCount}',
                                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          );
        }),
      ),
    );
  }
}
