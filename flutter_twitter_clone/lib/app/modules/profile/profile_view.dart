import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const _highlights = <String>[
    '完成了首页 Feed 的无限刷新。',
    '接入了 Node.js 后端，支持发布动态。',
    '新增了探索/社群/通知/私信页面。',
    '优化了深色主题和导航体验。',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        actions: [
          IconButton(
            onPressed: _showEditSheet,
            icon: const Icon(Icons.edit),
            tooltip: '编辑资料',
          ),
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            tooltip: '退出登录',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 300));
              controller.following.value += 1;
            },
            child: ListView(
              children: [
                Center(child: _buildAvatar(canEdit: true)),
                const SizedBox(height: 12),
                Text(controller.username.value,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(controller.handle.value, style: const TextStyle(color: Color(0xFF71767B))),
                Text(controller.email.value, style: const TextStyle(color: Color(0xFF71767B))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('${controller.following.value} 正在关注'),
                    const SizedBox(width: 18),
                    Text('${controller.followers.value} 关注者'),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: controller.toggleFollow,
                      child: Text(controller.isFollowing.value ? '已关注' : '关注'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('近期动态亮点', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ..._highlights.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bolt, color: Color(0xFF1D9BF0)),
                    title: Text(item),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar({bool canEdit = false}) {
    final localBytes = controller.localAvatarBytes.value;
    final url = controller.avatarUrl.value;
    final avatar = localBytes != null
        ? CircleAvatar(
            radius: 38,
            backgroundImage: MemoryImage(localBytes),
          )
        : url.isNotEmpty
        ? CircleAvatar(
            radius: 38,
            backgroundImage: NetworkImage(url),
            onBackgroundImageError: (_, __) {},
          )
        : const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 40));
    if (!canEdit) {
      return avatar;
    }

    return GestureDetector(
      onTap: controller.isUploadingAvatar.value ? null : controller.pickAvatarFromLocal,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1D9BF0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Get.theme.scaffoldBackgroundColor, width: 2),
              ),
              child: controller.isUploadingAvatar.value
                  ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet() {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Get.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('编辑资料', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildAvatar(canEdit: true),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: controller.clearAvatar,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('移除头像'),
                    ),
                  ),
                  TextField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(labelText: '昵称'),
                  ),
                  TextField(
                    controller: controller.handleController,
                    decoration: const InputDecoration(labelText: '账号（@xxx）'),
                  ),
                  TextField(
                    controller: controller.emailController,
                    decoration: const InputDecoration(labelText: '邮箱'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '当前密码（修改密码必填）'),
                  ),
                  TextField(
                    controller: controller.newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '新密码（可选）'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: controller.isSaving.value ? null : controller.saveProfile,
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('保存修改'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
