import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class AuthUser {
  AuthUser({
    required this.name,
    required this.handle,
    required this.email,
    required this.password,
  });

  String name;
  String handle;
  final String email;
  final String password;
}

class AuthController extends GetxController {
  final Rxn<AuthUser> currentUser = Rxn<AuthUser>();
  final RxBool isLoginMode = true.obs;
  final RxBool isSubmitting = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController handleController = TextEditingController();

  final List<AuthUser> _users = <AuthUser>[
    AuthUser(
      name: 'Halo User',
      handle: '@halo_user',
      email: 'halo@example.com',
      password: '123456',
    ),
  ];

  bool get isLoggedIn => currentUser.value != null;

  void toggleMode() {
    isLoginMode.toggle();
    if (isLoginMode.value) {
      nameController.clear();
      handleController.clear();
    }
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('提示', '请填写邮箱和密码');
      return;
    }

    if (!isLoginMode.value) {
      final name = nameController.text.trim();
      final handle = handleController.text.trim();
      if (name.isEmpty || handle.isEmpty) {
        Get.snackbar('提示', '注册请补充昵称与账号');
        return;
      }
    }

    try {
      isSubmitting.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 350));

      if (isLoginMode.value) {
        AuthUser? user;
        for (final item in _users) {
          if (item.email == email) {
            user = item;
            break;
          }
        }
        if (user == null || user.password != password) {
          Get.snackbar('登录失败', '邮箱或密码错误');
          return;
        }
        currentUser.value = user;
      } else {
        if (_users.any((item) => item.email == email)) {
          Get.snackbar('注册失败', '该邮箱已被注册');
          return;
        }
        final normalizedHandle = handleController.text.trim().startsWith('@')
            ? handleController.text.trim()
            : '@${handleController.text.trim()}';
        final created = AuthUser(
          name: nameController.text.trim(),
          handle: normalizedHandle,
          email: email,
          password: password,
        );
        _users.add(created);
        currentUser.value = created;
      }

      Get.offAllNamed(AppRoutes.home);
      Get.snackbar('成功', isLoginMode.value ? '欢迎回来' : '注册成功');
    } finally {
      isSubmitting.value = false;
    }
  }

  void logout() {
    currentUser.value = null;
    passwordController.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    handleController.dispose();
    super.onClose();
  }
}
