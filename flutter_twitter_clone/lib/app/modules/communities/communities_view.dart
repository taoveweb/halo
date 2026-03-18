import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';

class CommunitiesView extends StatelessWidget {
  const CommunitiesView({super.key});

  static const _communities = <Map<String, dynamic>>[
    {'name': 'Flutter 中文社区', 'members': '12.4K', 'tag': '移动开发'},
    {'name': '前端工程师联盟', 'members': '9.1K', 'tag': 'Web'},
    {'name': '独立开发者日记', 'members': '7.5K', 'tag': '创业'},
    {'name': '产品增长实验室', 'members': '5.3K', 'tag': '增长'},
    {'name': '设计系统研究所', 'members': '4.6K', 'tag': '设计'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社群'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: ListView.builder(
        itemCount: _communities.length,
        itemBuilder: (context, index) {
          final item = _communities[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF16181C),
            child: ListTile(
              leading: CircleAvatar(child: Text(item['name'].toString()[0])),
              title: Text(item['name'].toString()),
              subtitle: Text('${item['members']} 成员 · ${item['tag']}'),
              trailing: OutlinedButton(onPressed: () {}, child: const Text('加入')),
            ),
          );
        },
      ),
    );
  }
}
