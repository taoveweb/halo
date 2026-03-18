import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  static const _notifications = <Map<String, String>>[
    {'title': 'Halo Team 赞了你的动态', 'time': '2 分钟前'},
    {'title': 'Jane Doe 转发了你的动态', 'time': '8 分钟前'},
    {'title': '你关注的人 @dev_tom 发布了新动态', 'time': '22 分钟前'},
    {'title': 'Flutter 中文社区 回复了你', 'time': '1 小时前'},
    {'title': '你的动态获得了 10 次新点赞', 'time': '2 小时前'},
    {'title': '@product_amy 关注了你', 'time': '3 小时前'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: ListView.separated(
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF2F3336)),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications_none, color: Color(0xFF1D9BF0)),
            title: Text(item['title']!),
            subtitle: Text(item['time']!, style: const TextStyle(color: Color(0xFF71767B))),
          );
        },
      ),
    );
  }
}
