import 'dart:async';

import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../auth/auth_controller.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer(Duration(milliseconds: AppConstants.splashMinDurationMs), _goNext);
  }

  void _goNext() {
    final auth = Get.find<AuthController>();
    if (auth.isBootstrapping.value) {
      _timer = Timer(const Duration(milliseconds: 200), _goNext);
      return;
    }

    if (auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
