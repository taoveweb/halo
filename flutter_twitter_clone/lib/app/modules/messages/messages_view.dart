import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';
import '../social/social_controller.dart';

class MessagesView extends GetView<SocialController> {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('私信'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView.separated(
            itemCount: controller.chats.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFF2F3336)),
            itemBuilder: (context, index) {
              final item = controller.chats[index];
              return ListTile(
                onTap: () {
                  controller.openChat(item);
                  Get.snackbar('会话已打开', '你正在与 ${item.name} 聊天');
                },
                onLongPress: () => controller.togglePinChat(item),
                leading: CircleAvatar(child: Text(item.name[0].toUpperCase())),
                title: Row(
                  children: [
                    Expanded(child: Text(item.name)),
                    if (item.pinned)
                      const Icon(Icons.push_pin, size: 14, color: Color(0xFF1D9BF0)),
                  ],
                ),
                subtitle: Text(item.message,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.time,
                        style: const TextStyle(color: Color(0xFF71767B), fontSize: 12)),
                    if (item.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D9BF0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${item.unreadCount}',
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.snackbar('新建私信', '请输入联系人后开始聊天'),
        child: const Icon(Icons.mail_outline),
      ),
    );
  }
}
