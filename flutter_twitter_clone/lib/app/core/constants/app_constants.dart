import 'package:flutter/material.dart';

class AppConstants {
  /// 启动 Logo 资源路径（本地包内图片）。
  static const String splashLogoAsset = String.fromEnvironment(
    'APP_SPLASH_LOGO_ASSET',
    defaultValue: '',
  );

  /// 启动 Logo 图片地址，支持 http/https。
  static const String splashLogoUrl = String.fromEnvironment('APP_SPLASH_LOGO_URL');

  /// 启动 Logo 文本，作为图片加载失败或未配置时的兜底展示。
  static const String splashLogoText = String.fromEnvironment(
    'APP_SPLASH_LOGO_TEXT',
    defaultValue: 'Halo Social',
  );

  /// 启动屏最短展示时长（毫秒）。
  static const int splashMinDurationMs = int.fromEnvironment(
    'APP_SPLASH_MIN_DURATION_MS',
    defaultValue: 1200,
  );

  /// 启动阶段恢复会话时，校验登录态请求超时时间（毫秒）。
  static const int authBootstrapTimeoutMs = int.fromEnvironment(
    'APP_AUTH_BOOTSTRAP_TIMEOUT_MS',
    defaultValue: 6000,
  );

  static const Color brandColor = Color(0xFF1D9BF0);
}
