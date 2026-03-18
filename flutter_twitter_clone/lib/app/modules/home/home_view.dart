import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/tweet_card.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主页'),
        actions: const [
          Padding(
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF71767B),
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 3) {
            Get.toNamed(AppRoutes.profile);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ''),
        ],
      ),
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
                onTap: () => Get.toNamed(AppRoutes.tweetDetail, arguments: tweet),
              );
            },
          ),
        );
      }),
    );
  }
}
