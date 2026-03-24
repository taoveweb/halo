import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (AppConstants.splashLogoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          AppConstants.splashLogoUrl,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _logoText(),
        ),
      );
    }

    return _logoText();
  }

  Widget _logoText() {
    return Text(
      AppConstants.splashLogoText,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppConstants.brandColor,
      ),
    );
  }
}
