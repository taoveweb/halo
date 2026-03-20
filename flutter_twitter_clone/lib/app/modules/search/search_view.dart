import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/tweet_card.dart';
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
                onSubmitted: (_) => controller.search(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '搜索话题或推文内容',
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
                if (controller.searchLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.searchError.value != null) {
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
                            onPressed: controller.search,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final hasQuery = controller.searchQuery.value.trim().isNotEmpty;
                if (!hasQuery) {
                  return Center(
                    child: Text(
                      '输入关键词搜索话题或推文内容',
                      style: const TextStyle(color: Color(0xFF71767B)),
                    ),
                  );
                }
                if (controller.searchTweets.isEmpty && controller.topics.isEmpty) {
                  return const Center(
                    child: Text(
                      '没有找到相关话题或推文，换个关键词试试',
                      style: TextStyle(color: Color(0xFF71767B)),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshAll,
                  child: ListView(
                    children: [
                      if (controller.topics.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            '话题',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        ...controller.topics.map(
                          (topic) => ListTile(
                            leading: const Icon(Icons.tag, color: Color(0xFF71767B)),
                            title: Text(topic.title),
                            subtitle: Text('${topic.posts} 条动态'),
                            trailing: FilledButton.tonal(
                              onPressed: () => controller.toggleTopicFollow(topic),
                              child: Text(topic.following ? '已关注' : '关注'),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFF2F3336)),
                      ],
                      if (controller.searchTweets.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            '推文',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        ...controller.searchTweets.map((tweet) {
                          return TweetCard(
                            tweet: tweet,
                            onTap: () => Get.toNamed(AppRoutes.tweetDetail, arguments: tweet),
                            onShare: () async {
                              final text = '${tweet.author} ${tweet.handle}\n${tweet.content}';
                              await Clipboard.setData(ClipboardData(text: text));
                              Get.snackbar('已复制', '动态内容已复制到剪贴板', snackPosition: SnackPosition.BOTTOM);
                            },
                          );
                        }),
                      ],
                    ],
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
