import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/models/tweet_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/tweet_card.dart';
import '../auth/auth_controller.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
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
                        canManage: authController.currentUser.value?.handle == tweet.handle,
                        onLike: () => controller.toggleLike(tweet),
                        onRetweet: () => controller.toggleRetweet(tweet),
                        onEdit: () => _showEditDialog(context, tweet),
                        onDelete: () => _confirmDelete(tweet),
                        onComment: () async {
                          await controller.recordTweetView(tweet);
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
                          await controller.recordTweetView(tweet);
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

  Future<void> _showEditDialog(BuildContext context, TweetModel tweet) async {
    final inputController = TextEditingController(text: tweet.content);
    final content = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新编辑'),
        content: TextField(
          controller: inputController,
          maxLength: 280,
          minLines: 2,
          maxLines: 6,
          decoration: const InputDecoration(hintText: '编辑动态内容'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, inputController.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (content == null || content.isEmpty || content == tweet.content) {
      return;
    }

    try {
      await controller.editTweet(tweet: tweet, content: content);
      Get.snackbar('成功', '动态已更新', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('编辑失败', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _confirmDelete(TweetModel tweet) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('删除动态'),
        content: const Text('确认删除这条动态吗？此操作无法撤销。'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('删除')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await controller.deleteTweet(tweet);
      Get.snackbar('成功', '动态已删除', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('删除失败', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
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
