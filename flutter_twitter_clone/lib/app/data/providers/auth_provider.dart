import 'dart:convert';
import 'dart:typed_data';

import '../../core/network/api_client.dart';

class AuthProvider {
  AuthProvider(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      '/auth/login',
      withAuth: false,
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      throw Exception('登录失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String handle,
    required String email,
    required String password,
    String? avatarUrl,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      withAuth: false,
      body: {
        'name': name,
        'handle': handle,
        'email': email,
        'password': password,
        'avatarUrl': avatarUrl,
      },
    );

    if (response.statusCode != 201) {
      throw Exception('注册失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchMe() async {
    final response = await _apiClient.get('/auth/me');

    if (response.statusCode != 200) {
      throw Exception('登录状态失效: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? handle,
    String? email,
    String? avatarUrl,
    bool clearAvatar = false,
    String? currentPassword,
    String? newPassword,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (handle != null) payload['handle'] = handle;
    if (email != null) payload['email'] = email;
    if (avatarUrl != null) {
      payload['avatarUrl'] = avatarUrl;
    } else if (clearAvatar) {
      payload['avatarUrl'] = null;
    }
    if (currentPassword != null && newPassword != null) {
      payload['currentPassword'] = currentPassword;
      payload['newPassword'] = newPassword;
    }

    final response = await _apiClient.patch('/auth/profile', body: payload);

    if (response.statusCode != 200) {
      throw Exception('更新资料失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<String> uploadAvatar({
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
  }) async {
    final base64Image = base64Encode(bytes);
    final response = await _apiClient.post(
      '/auth/avatar',
      body: {
        'imageBase64': 'data:$mimeType;base64,$base64Image',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('上传头像失败: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final avatarUrl = data['avatarUrl'] as String?;
    if (avatarUrl == null || avatarUrl.isEmpty) {
      throw Exception('上传头像失败: 服务端未返回头像地址');
    }
    return avatarUrl;
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }
}
