import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../modules/social/social_controller.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const _routes = <String>[
    AppRoutes.home,
    AppRoutes.search,
    AppRoutes.communities,
    AppRoutes.notifications,
    AppRoutes.messages,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFF71767B),
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) {
          return;
        }
        final targetRoute = _routes[index];
        Get.offNamed(targetRoute);
      },
      items: _buildItems(),
      );
    });
  }

  List<BottomNavigationBarItem> _buildItems() {
    final social = Get.isRegistered<SocialController>() ? Get.find<SocialController>() : null;
    final unread = social?.unreadNotificationCount.value ?? 0;

    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
      const BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
      const BottomNavigationBarItem(icon: Icon(Icons.remove_red_eye_outlined), label: ''),
      BottomNavigationBarItem(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none),
            if (unread > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      unread > 99 ? '99+' : unread.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              )
          ],
        ),
        label: '',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ''),
    ];
  }
}
