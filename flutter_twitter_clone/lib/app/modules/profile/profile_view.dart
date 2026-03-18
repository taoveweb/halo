import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const _highlights = <String>[
    '完成了首页 Feed 的无限刷新。',
    '接入了 Node.js 后端，支持发布动态。',
    '新增了探索/社群/通知/私信页面。',
    '优化了深色主题和导航体验。',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => ListView(
            children: [
              const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 40)),
              const SizedBox(height: 12),
              Text(controller.username.value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(controller.handle.value,
                  style: const TextStyle(color: Color(0xFF71767B))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${controller.following.value} 正在关注'),
                  const SizedBox(width: 18),
                  Text('${controller.followers.value} 关注者'),
                ],
              ),
              const SizedBox(height: 20),
              const Text('近期动态亮点',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ..._highlights.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bolt, color: Color(0xFF1D9BF0)),
                  title: Text(item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
