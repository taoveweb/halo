import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 40)),
              const SizedBox(height: 12),
              Text(controller.username.value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(controller.handle.value,
                  style: const TextStyle(color: Color(0xFF71767B))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${controller.following.value} 正在关注'),
                  const SizedBox(width: 18),
                  Text('${controller.followers.value} 关注者'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
