import '../models/auth_user_model.dart';
import '../providers/auth_provider.dart';

class AuthResult {
  AuthResult({required this.token, required this.user});

  final String token;
  final AuthUserModel user;
}

class AuthService {
  AuthService(this._provider);

  final AuthProvider _provider;

  Future<AuthResult> login({required String email, required String password}) async {
    final data = await _provider.login(email: email, password: password);
    return AuthResult(
      token: data['token'] as String,
      user: AuthUserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthResult> register({
    required String name,
    required String handle,
    required String email,
    required String password,
  }) async {
    final data = await _provider.register(
      name: name,
      handle: handle,
      email: email,
      password: password,
    );

    return AuthResult(
      token: data['token'] as String,
      user: AuthUserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthUserModel> fetchMe(String token) async {
    final data = await _provider.fetchMe(token);
    return AuthUserModel.fromJson(data);
  }

  Future<void> logout(String token) {
    return _provider.logout(token);
  }
}
