import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';
import '../social/social_controller.dart';

class NotificationsView extends GetView<SocialController> {
  const NotificationsView({super.key});

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes 分钟前';
    if (minutes < 1440) return '${minutes ~/ 60} 小时前';
    return '${minutes ~/ 1440} 天前';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        actions: [
          IconButton(
            onPressed: () => controller.markAllNotificationsRead(),
            icon: const Icon(Icons.done_all),
            tooltip: '全部标为已读',
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Obx(() {
              return SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('全部')),
                  ButtonSegment(value: 1, label: Text('未读')),
                ],
                selected: {controller.selectedNotificationFilter.value},
                onSelectionChanged: (selection) =>
                    controller.setNotificationFilter(selection.first),
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              final list = controller.filteredNotifications;
              return RefreshIndicator(
                onRefresh: controller.refreshAll,
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFF2F3336)),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return ListTile(
                      onTap: () => controller.markNotificationRead(item),
                      leading: Icon(
                        item.read
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: item.read
                            ? const Color(0xFF71767B)
                            : const Color(0xFF1D9BF0),
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        _formatTime(item.minutesAgo),
                        style: const TextStyle(color: Color(0xFF71767B)),
                      ),
                      trailing: item.read
                          ? null
                          : const Icon(Icons.brightness_1,
                              size: 8, color: Color(0xFF1D9BF0)),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
