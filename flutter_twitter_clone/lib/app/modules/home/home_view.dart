import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/tweet_card.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主页'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.auto_awesome_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1D9BF0),
        onPressed: () async {
          final posted = await Get.toNamed(AppRoutes.compose);
          if (posted == true) {
            controller.loadTimeline();
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.error.value, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.loadTimeline,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Row(
                children: [
                  _FeedTab(
                    title: '为你推荐',
                    selected: controller.selectedFeed.value == 'for_you',
                    onTap: () => controller.switchFeed('for_you'),
                  ),
                  const SizedBox(width: 8),
                  _FeedTab(
                    title: '正在关注',
                    selected: controller.selectedFeed.value == 'following',
                    onTap: () => controller.switchFeed('following'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadTimeline,
                child: ListView.builder(
                  itemCount: controller.tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = controller.tweets[index];
                    return TweetCard(
                      tweet: tweet,
                      onLike: () => controller.toggleLike(tweet),
                      onRetweet: () => controller.toggleRetweet(tweet),
                      onComment: () async {
                        final updated = await Get.toNamed(AppRoutes.tweetDetail, arguments: tweet);
                        if (updated == true) {
                          controller.loadTimeline();
                        }
                      },
                      onShare: () async {
                        final text = '${tweet.author} ${tweet.handle}\n${tweet.content}';
                        await Clipboard.setData(ClipboardData(text: text));
                        Get.snackbar('已复制', '动态内容已复制到剪贴板', snackPosition: SnackPosition.BOTTOM);
                      },
                      onTap: () async {
                        final updated = await Get.toNamed(AppRoutes.tweetDetail, arguments: tweet);
                        if (updated == true) {
                          controller.loadTimeline();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? const Color(0xFF1D9BF0) : const Color(0xFF16181C),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF71767B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
