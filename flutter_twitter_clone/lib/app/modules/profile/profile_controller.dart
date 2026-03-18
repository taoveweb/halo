import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/auth_controller.dart';

class ProfileController extends GetxController {
  ProfileController(this._authController);

  final AuthController _authController;

  final RxString username = 'Halo User'.obs;
  final RxString handle = '@halo_user'.obs;
  final RxString email = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxInt followers = 128.obs;
  final RxInt following = 86.obs;
  final RxBool isFollowing = false.obs;
  final RxBool isSaving = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController handleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController avatarController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _syncFromAuth();

    ever(_authController.currentUser, (_) => _syncFromAuth());

    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      followers.value += 1;
    });
  }

  void _syncFromAuth() {
    final user = _authController.currentUser.value;
    if (user == null) return;

    username.value = user.name;
    handle.value = user.handle;
    email.value = user.email;
    avatarUrl.value = user.avatarUrl ?? '';

    nameController.text = user.name;
    handleController.text = user.handle;
    emailController.text = user.email;
    avatarController.text = user.avatarUrl ?? '';
  }

  void logout() {
    _authController.logout();
  }

  void toggleFollow() {
    isFollowing.toggle();
    followers.value += isFollowing.value ? 1 : -1;
  }

  Future<void> saveProfile() async {
    if (isSaving.value) return;

    final name = nameController.text.trim();
    final nextHandle = handleController.text.trim();
    final nextEmail = emailController.text.trim().toLowerCase();
    final nextAvatar = avatarController.text.trim();
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (name.isEmpty || nextHandle.isEmpty || nextEmail.isEmpty) {
      Get.snackbar('提示', '姓名、账号、邮箱不能为空');
      return;
    }

    if (newPassword.isNotEmpty && currentPassword.isEmpty) {
      Get.snackbar('提示', '修改密码请先填写当前密码');
      return;
    }

    if (newPassword.isNotEmpty && newPassword.length < 6) {
      Get.snackbar('提示', '新密码至少 6 位');
      return;
    }

    try {
      isSaving.value = true;
      await _authController.updateProfile(
        name: name,
        handle: nextHandle,
        email: nextEmail,
        avatarUrl: nextAvatar.isEmpty ? null : nextAvatar,
        clearAvatar: nextAvatar.isEmpty,
        currentPassword: newPassword.isNotEmpty ? currentPassword : null,
        newPassword: newPassword.isNotEmpty ? newPassword : null,
      );

      currentPasswordController.clear();
      newPasswordController.clear();
      _syncFromAuth();
      Get.back<void>();
      Get.snackbar('成功', '个人资料已更新');
    } catch (e) {
      Get.snackbar('更新失败', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    nameController.dispose();
    handleController.dispose();
    emailController.dispose();
    avatarController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
