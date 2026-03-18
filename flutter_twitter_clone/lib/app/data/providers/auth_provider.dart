import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class AuthProvider {
  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
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
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'handle': handle,
        'email': email,
        'password': password,
        'avatarUrl': avatarUrl,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('注册失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchMe(String token) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('登录状态失效: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
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

    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('更新资料失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> logout(String token) async {
    await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
