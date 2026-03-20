import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class TweetProvider {
  final http.Client _client = http.Client();
  String? _token;

  void setAuthToken(String? token) {
    _token = token;
  }

  Map<String, String> _jsonHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<List<dynamic>> fetchTimeline({required String feed, String? query}) async {
    final queryParams = <String, String>{'feed': feed};
    if (query != null && query.trim().isNotEmpty) {
      queryParams['query'] = query.trim();
    }
    final uri = Uri.parse('${ApiConstants.baseUrl}/tweets').replace(queryParameters: queryParams);
    final response = await _client.get(uri, headers: _jsonHeaders());

    if (response.statusCode != 200) {
      throw Exception('加载动态失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postTweet({
    required String content,
    List<Map<String, String>> media = const [],
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/tweets'),
      headers: _jsonHeaders(),
      body: jsonEncode({'content': content, 'media': media}),
    );

    if (response.statusCode != 201) {
      throw Exception('发布动态失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchTweetById(String tweetId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/tweets/$tweetId'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('加载动态失败: ${response.body}');
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
      headers: _jsonHeaders(),
      body: jsonEncode({'active': active}),
    );

    if (response.statusCode != 200) {
      throw Exception('更新互动失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTweet({
    required String tweetId,
    required String content,
  }) async {
    final response = await _client.patch(
      Uri.parse('${ApiConstants.baseUrl}/tweets/$tweetId'),
      headers: _jsonHeaders(),
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('编辑动态失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteTweet(String tweetId) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.baseUrl}/tweets/$tweetId'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('删除动态失败: ${response.body}');
    }
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
      headers: _jsonHeaders(),
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 201) {
      throw Exception('评论失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchTopics({String? query}) async {
    final encodedQuery = query == null || query.isEmpty ? '' : '?query=${Uri.encodeQueryComponent(query)}';
    final response =
        await _client.get(Uri.parse('${ApiConstants.baseUrl}/topics$encodedQuery'), headers: _jsonHeaders());

    if (response.statusCode != 200) {
      throw Exception('加载话题失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateTopicFollow({required String topicId, required bool active}) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/topics/$topicId/follow'),
      headers: _jsonHeaders(),
      body: jsonEncode({'active': active}),
    );

    if (response.statusCode != 200) {
      throw Exception('更新关注失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createTopic({required String title}) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/topics'),
      headers: _jsonHeaders(),
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode != 201) {
      throw Exception('创建话题失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchCommunities() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/communities'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('加载社群失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateCommunityJoin({
    required String communityId,
    required bool active,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/communities/$communityId/join'),
      headers: _jsonHeaders(),
      body: jsonEncode({'active': active}),
    );

    if (response.statusCode != 200) {
      throw Exception('更新社群状态失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recordTweetView(String tweetId) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}/tweets/$tweetId/view'),
      headers: _jsonHeaders(),
      body: jsonEncode({}),
    );

    if (response.statusCode != 200) {
      throw Exception('记录浏览失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
