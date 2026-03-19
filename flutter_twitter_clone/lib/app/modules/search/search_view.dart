import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';
import '../social/social_controller.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final SocialController controller = Get.find<SocialController>();
  late final TextEditingController _searchTextController;

  @override
  void initState() {
    super.initState();
    _searchTextController = TextEditingController(text: controller.searchQuery.value);
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('探索'),
        actions: [
          IconButton(
            onPressed: () => _showCreateTopicDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '新建话题',
          ),
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
            child: Obx(
              () => TextField(
                controller: _searchTextController,
                onChanged: controller.setSearchQuery,
                onSubmitted: (_) => controller.loadTopics(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '搜索话题或关键字',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.searchQuery.value.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchTextController.clear();
                            controller.clearSearchQuery();
                          },
                          icon: const Icon(Icons.close),
                          tooltip: '清空搜索',
                        ),
                  filled: true,
                  fillColor: const Color(0xFF16181C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                final topics = controller.filteredTopics;
                if (controller.topicLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.topicError.value != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: Color(0xFF71767B)),
                          const SizedBox(height: 10),
                          const Text('搜索失败，请检查网络后重试'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: controller.loadTopics,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (topics.isEmpty) {
                  return Center(
                    child: Text(
                      controller.searchQuery.value.trim().isEmpty
                          ? '暂无推荐话题'
                          : '没有找到相关话题，换个关键词试试',
                      style: const TextStyle(color: Color(0xFF71767B)),
                    ),
                  );
                }

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
                          onPressed: () async => controller.toggleTopicFollow(item),
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

  Future<void> _showCreateTopicDialog(BuildContext context) async {
    final textController = TextEditingController();
    await Get.dialog(
      AlertDialog(
        title: const Text('新建话题'),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            hintText: '输入话题名，例如 #HaloSocial',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          Obx(
            () => FilledButton(
              onPressed: controller.topicCreating.value
                  ? null
                  : () async {
                      final title = textController.text.trim();
                      if (title.isEmpty) {
                        return;
                      }
                      await controller.createTopic(title);
                      if (context.mounted) {
                        Get.back();
                      }
                    },
              child: controller.topicCreating.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('创建'),
            ),
          ),
        ],
      ),
    );
    textController.dispose();
  }
}
