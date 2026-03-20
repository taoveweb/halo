import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.remove_red_eye_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ''),
      ],
    );
  }
}
