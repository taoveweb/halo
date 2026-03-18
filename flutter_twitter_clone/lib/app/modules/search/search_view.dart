import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';
import '../social/social_controller.dart';

class SearchView extends GetView<SocialController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('探索'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: '搜索话题或关键字',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF16181C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                final topics = controller.filteredTopics;
                return RefreshIndicator(
                  onRefresh: controller.refreshAll,
                  child: ListView.separated(
                    itemCount: topics.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFF2F3336)),
                    itemBuilder: (context, index) {
                      final item = topics[index];
                      return ListTile(
                        title: Text(item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${item.posts} 条动态',
                            style: const TextStyle(color: Color(0xFF71767B))),
                        trailing: FilledButton.tonal(
                          onPressed: () => controller.toggleTopicFollow(item),
                          child: Text(item.following ? '已关注' : '关注'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
