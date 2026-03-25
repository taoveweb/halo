class ApiConstants {
  /// 环境标识，可通过 `--dart-define=APP_ENV=prod|test|dev` 指定。
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  /// 如果显式传入 API_URL，则优先使用该值。
  static const String _overrideBaseUrl = String.fromEnvironment('API_URL');

  static const String _devBaseUrl = String.fromEnvironment(
    'API_URL_DEV',
    defaultValue: 'http://localhost:3000/api',
  );

  static const String _testBaseUrl = String.fromEnvironment(
    'API_URL_TEST',
    defaultValue: 'http://172.20.10.2:3000/api',
  );

  static const String _prodBaseUrl = String.fromEnvironment(
    'API_URL_PROD',
    defaultValue: 'http://localhost:3000/api',
  );

  /// 最终 API 地址：
  /// 1) API_URL（强制覆盖）
  /// 2) 按 APP_ENV 选择 API_URL_DEV / API_URL_TEST / API_URL_PROD
  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }
    switch (appEnv) {
      case 'prod':
        return _prodBaseUrl;
      case 'test':
        return _testBaseUrl;
      default:
        return _devBaseUrl;
    }
  }
}
  