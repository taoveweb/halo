import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class TweetProvider {
  final http.Client _client = http.Client();

  Future<List<dynamic>> fetchTimeline({required String feed}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/tweets?feed=$feed');
    final response = await _client.get(uri);

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

  Future<Map<String, dynamic>> updateTweetInteraction({
    required String tweetId,
    required String action,
    required bool active,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/tweets/$tweetId/$action'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'active': active}),
    );

    if (response.statusCode != 200) {
      throw Exception('更新互动失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchComments(String tweetId) async {
    final response = await _client.get(Uri.parse('${ApiConstants.baseUrl}/tweets/$tweetId/comments'));

    if (response.statusCode != 200) {
      throw Exception('加载评论失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postComment({required String tweetId, required String content}) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/tweets/$tweetId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 201) {
      throw Exception('评论失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchTopics({String? query}) async {
    final encodedQuery = query == null || query.isEmpty ? '' : '?query=${Uri.encodeQueryComponent(query)}';
    final response = await _client.get(Uri.parse('${ApiConstants.baseUrl}/topics$encodedQuery'));

    if (response.statusCode != 200) {
      throw Exception('加载话题失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateTopicFollow({required String topicId, required bool active}) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/topics/$topicId/follow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'active': active}),
    );

    if (response.statusCode != 200) {
      throw Exception('更新关注失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
