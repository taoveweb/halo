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
                onSubmitted: (_) => controller.loadSearchTweets(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '搜索推文内容',
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
                            onPressed: controller.loadSearchTweets,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (controller.searchTweets.isEmpty) {
                  return Center(
                    child: Text(
                      controller.searchQuery.value.trim().isEmpty
                          ? '输入关键词搜索推文内容'
                          : '没有找到相关推文，换个关键词试试',
                      style: const TextStyle(color: Color(0xFF71767B)),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshAll,
                  child: ListView.builder(
                    itemCount: controller.searchTweets.length,
                    itemBuilder: (context, index) {
                      final tweet = controller.searchTweets[index];
                      return TweetCard(
                        tweet: tweet,
                        onTap: () => Get.toNamed(AppRoutes.tweetDetail, arguments: tweet),
                        onShare: () async {
                          final text = '${tweet.author} ${tweet.handle}\n${tweet.content}';
                          await Clipboard.setData(ClipboardData(text: text));
                          Get.snackbar('已复制', '动态内容已复制到剪贴板', snackPosition: SnackPosition.BOTTOM);
                        },
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
