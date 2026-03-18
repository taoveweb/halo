import 'package:flutter/material.dart';
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

        return RefreshIndicator(
          onRefresh: controller.loadTimeline,
          child: ListView.builder(
            itemCount: controller.tweets.length,
            itemBuilder: (context, index) {
              final tweet = controller.tweets[index];
              return TweetCard(
                tweet: tweet,
                onTap: () async {
                  final updated =
                      await Get.toNamed(AppRoutes.tweetDetail, arguments: tweet);
                  if (updated == true) {
                    controller.loadTimeline();
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }
}
