import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/auth_user_model.dart';
import '../../data/providers/tweet_provider.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  AuthController(this._authService, this._tweetProvider);

  static const _sessionTokenKey = 'session_token';
  static const _sessionUserKey = 'session_user';

  final AuthService _authService;
  final TweetProvider _tweetProvider;

  final Rxn<AuthUserModel> currentUser = Rxn<AuthUserModel>();
  final RxnString token = RxnString();
  final RxBool isLoginMode = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isBootstrapping = true.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController handleController = TextEditingController();

  bool get isLoggedIn => currentUser.value != null && (token.value?.isNotEmpty ?? false);

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_sessionTokenKey);
      final savedUserRaw = prefs.getString(_sessionUserKey);
      if (savedToken == null || savedUserRaw == null) {
        return;
      }

      token.value = savedToken;
      _tweetProvider.setAuthToken(savedToken);

      final savedUserMap = jsonDecode(savedUserRaw) as Map<String, dynamic>;
      currentUser.value = AuthUserModel.fromJson(savedUserMap);

      final verifiedUser = await _authService.fetchMe(savedToken);
      currentUser.value = verifiedUser;
      await prefs.setString(_sessionUserKey, jsonEncode(verifiedUser.toJson()));

      if (Get.currentRoute == AppRoutes.login) {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (_) {
      await _clearSession();
    } finally {
      isBootstrapping.value = false;
    }
  }

  Future<void> _saveSession({required String sessionToken, required AuthUserModel user}) async {
    token.value = sessionToken;
    currentUser.value = user;
    _tweetProvider.setAuthToken(sessionToken);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionTokenKey, sessionToken);
    await prefs.setString(_sessionUserKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    token.value = null;
    currentUser.value = null;
    _tweetProvider.setAuthToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_sessionUserKey);
  }

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

      final result = isLoginMode.value
          ? await _authService.login(email: email, password: password)
          : await _authService.register(
              name: nameController.text.trim(),
              handle: handleController.text.trim(),
              email: email,
              password: password,
            );

      await _saveSession(sessionToken: result.token, user: result.user);
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar('成功', isLoginMode.value ? '欢迎回来' : '注册成功');
    } catch (e) {
      Get.snackbar(isLoginMode.value ? '登录失败' : '注册失败', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> logout() async {
    final currentToken = token.value;
    try {
      if (currentToken != null && currentToken.isNotEmpty) {
        await _authService.logout(currentToken);
      }
    } finally {
      await _clearSession();
      passwordController.clear();
      Get.offAllNamed(AppRoutes.login);
    }
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
