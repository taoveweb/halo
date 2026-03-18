import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class TweetProvider {
  final http.Client _client = http.Client();

  Future<List<dynamic>> fetchTimeline() async {
    final response = await _client.get(Uri.parse('${ApiConstants.baseUrl}/tweets'));

    if (response.statusCode != 200) {
      throw Exception('加载动态失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postTweet({required String content}) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/tweets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 201) {
      throw Exception('发布动态失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
