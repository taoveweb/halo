import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';
import '../social/social_controller.dart';

class CommunitiesView extends GetView<SocialController> {
  const CommunitiesView({super.key});

  String _formatMembers(int members) {
    if (members >= 10000) {
      return '${(members / 1000).toStringAsFixed(1)}K';
    }
    return '$members';
  }

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
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView.builder(
            itemCount: controller.communities.length,
            itemBuilder: (context, index) {
              final item = controller.communities[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color(0xFF16181C),
                child: ListTile(
                  leading: CircleAvatar(child: Text(item.name[0])),
                  title: Text(item.name),
                  subtitle: Text('${_formatMembers(item.members)} 成员 · ${item.tag}'),
                  trailing: OutlinedButton(
                    onPressed: () => controller.joinCommunity(item),
                    child: Text(item.joined ? '已加入' : '加入'),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
