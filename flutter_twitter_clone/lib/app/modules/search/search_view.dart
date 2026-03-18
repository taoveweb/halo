import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  static const _trendingTopics = <Map<String, String>>[
    {'title': '#Flutter', 'subtitle': '1.2万 条动态'},
    {'title': '#GetX', 'subtitle': '4,362 条动态'},
    {'title': '#HaloSocial', 'subtitle': '2,993 条动态'},
    {'title': '#AIProductivity', 'subtitle': '8,501 条动态'},
    {'title': '#OpenSource', 'subtitle': '6,218 条动态'},
    {'title': '#NodeJS', 'subtitle': '3,887 条动态'},
  ];

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
      body: ListView.separated(
        itemCount: _trendingTopics.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF2F3336)),
        itemBuilder: (context, index) {
          final item = _trendingTopics[index];
          return ListTile(
            title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(item['subtitle']!, style: const TextStyle(color: Color(0xFF71767B))),
            trailing: const Icon(Icons.more_horiz, color: Color(0xFF71767B)),
          );
        },
      ),
    );
  }
}
