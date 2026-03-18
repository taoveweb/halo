import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key});

  static const _chats = <Map<String, String>>[
    {'name': 'Jane Doe', 'message': '首页交互我已经提交 PR 啦。', 'time': '刚刚'},
    {'name': 'Halo Team', 'message': '今晚 8 点上线新版本，记得回归测试。', 'time': '12:20'},
    {'name': 'dev_tom', 'message': '可以把评论接口也接一下吗？', 'time': '昨天'},
    {'name': 'product_amy', 'message': '下周加上推荐流页面如何？', 'time': '周二'},
    {'name': 'design_lily', 'message': '我更新了深色主题规范。', 'time': '周一'},
  ];

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
      body: ListView.separated(
        itemCount: _chats.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF2F3336)),
        itemBuilder: (context, index) {
          final item = _chats[index];
          return ListTile(
            leading: CircleAvatar(child: Text(item['name']![0].toUpperCase())),
            title: Text(item['name']!),
            subtitle: Text(item['message']!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(item['time']!, style: const TextStyle(color: Color(0xFF71767B))),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.mail_outline),
      ),
    );
  }
}
