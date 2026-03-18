import 'dart:async';

import 'package:get/get.dart';

import '../auth/auth_controller.dart';

class ProfileController extends GetxController {
  ProfileController(this._authController);

  final AuthController _authController;

  final RxString username = 'Halo User'.obs;
  final RxString handle = '@halo_user'.obs;
  final RxInt followers = 128.obs;
  final RxInt following = 86.obs;
  final RxBool isFollowing = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final user = _authController.currentUser.value;
    if (user != null) {
      username.value = user.name;
      handle.value = user.handle;
    }
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      followers.value += 1;
    });
  }

  void logout() {
    _authController.logout();
  }

  void toggleFollow() {
    isFollowing.toggle();
    followers.value += isFollowing.value ? 1 : -1;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
