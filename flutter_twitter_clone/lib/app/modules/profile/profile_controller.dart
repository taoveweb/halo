import 'dart:async';

import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxString username = 'Halo User'.obs;
  final RxString handle = '@halo_user'.obs;
  final RxInt followers = 128.obs;
  final RxInt following = 86.obs;
  final RxBool isFollowing = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      followers.value += 1;
    });
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
