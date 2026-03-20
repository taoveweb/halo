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

        return SafeArea(
          child: Column(
            children: [
              const _HomeHeader(),
              _TopTabs(
                selectedFeed: controller.selectedFeed.value,
                onSwitch: controller.switchFeed,
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
          ),
        );
      }),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.toNamed(AppRoutes.profile),
            borderRadius: BorderRadius.circular(20),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF2F3336),
              child: Icon(Icons.person, size: 22, color: Color(0xFFD6D9DB)),
            ),
          ),
          const Spacer(),
          const Text(
            'X',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w300,
              letterSpacing: -2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2F3336)),
            ),
            child: const Text(
              '订阅',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({
    required this.selectedFeed,
    required this.onSwitch,
  });

  final String selectedFeed;
  final Future<void> Function(String feed) onSwitch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF2F3336), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _FeedTab(
            title: '为你推荐',
            selected: selectedFeed == 'for_you',
            onTap: () => onSwitch('for_you'),
          ),
          _FeedTab(
            title: '正在关注',
            selected: selectedFeed == 'following',
            onTap: () => onSwitch('following'),
          ),
        ],
      ),
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF71767B),
                fontSize: 24 / 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (selected)
              const Positioned(
                bottom: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF1D9BF0),
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                  child: SizedBox(width: 64, height: 4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
