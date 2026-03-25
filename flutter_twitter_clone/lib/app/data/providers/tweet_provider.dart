import 'dart:convert';

import '../../core/network/api_client.dart';

class TweetProvider {
  TweetProvider(this._apiClient);

  final ApiClient _apiClient;

  Future<List<dynamic>> fetchTimeline({required String feed, String? query}) async {
    final queryParams = <String, String>{'feed': feed};
    if (query != null && query.trim().isNotEmpty) {
      queryParams['query'] = query.trim();
    }
    final response = await _apiClient.get('/tweets', queryParameters: queryParams);

    if (response.statusCode != 200) {
      throw Exception('加载动态失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postTweet({
    required String content,
    List<Map<String, String>> media = const [],
  }) async {
    final response = await _apiClient.post('/tweets', body: {'content': content, 'media': media});

    if (response.statusCode != 201) {
      throw Exception('发布动态失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchTweetById(String tweetId) async {
    final response = await _apiClient.get('/tweets/$tweetId');

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
    final response = await _apiClient.post(
      '/tweets/$tweetId/$action',
      body: {'active': active},
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
    final response = await _apiClient.patch('/tweets/$tweetId', body: {'content': content});

    if (response.statusCode != 200) {
      throw Exception('编辑动态失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteTweet(String tweetId) async {
    final response = await _apiClient.delete('/tweets/$tweetId');

    if (response.statusCode != 204) {
      throw Exception('删除动态失败: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchComments(String tweetId) async {
    final response = await _apiClient.get('/tweets/$tweetId/comments', withAuth: false);

    if (response.statusCode != 200) {
      throw Exception('加载评论失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postComment({required String tweetId, required String content}) async {
    final response = await _apiClient.post('/tweets/$tweetId/comments', body: {'content': content});

    if (response.statusCode != 201) {
      throw Exception('评论失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchTopics({String? query}) async {
    final queryParams = <String, String>{};
    if (query != null && query.isNotEmpty) {
      queryParams['query'] = query;
    }
    final response = await _apiClient.get('/topics', queryParameters: queryParams.isEmpty ? null : queryParams);

    if (response.statusCode != 200) {
      throw Exception('加载话题失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateTopicFollow({required String topicId, required bool active}) async {
    final response = await _apiClient.post('/topics/$topicId/follow', body: {'active': active});

    if (response.statusCode != 200) {
      throw Exception('更新关注失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createTopic({required String title}) async {
    final response = await _apiClient.post('/topics', body: {'title': title});

    if (response.statusCode != 201) {
      throw Exception('创建话题失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchCommunities() async {
    final response = await _apiClient.get('/communities');

    if (response.statusCode != 200) {
      throw Exception('加载社群失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateCommunityJoin({
    required String communityId,
    required bool active,
  }) async {
    final response = await _apiClient.post('/communities/$communityId/join', body: {'active': active});

    if (response.statusCode != 200) {
      throw Exception('更新社群状态失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchNotifications() async {
    final response = await _apiClient.get('/notifications');

    if (response.statusCode != 200) {
      throw Exception('加载通知失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> markNotificationRead(String notificationId) async {
    final response = await _apiClient.post('/notifications/$notificationId/read', body: {});

    if (response.statusCode != 200) {
      throw Exception('更新通知状态失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> markAllNotificationsRead() async {
    final response = await _apiClient.post('/notifications/read-all', body: {});

    if (response.statusCode != 200) {
      throw Exception('更新通知状态失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<List<dynamic>> fetchChats() async {
    final response = await _apiClient.get('/chats');

    if (response.statusCode != 200) {
      throw Exception('加载私信失败: ${response.body}');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }


  Future<Map<String, dynamic>> fetchChatDetail(String chatId) async {
    final response = await _apiClient.get('/chats/$chatId');

    if (response.statusCode != 200) {
      throw Exception('加载会话详情失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required String chatId,
    required String text,
  }) async {
    final response = await _apiClient.post('/chats/$chatId/messages', body: {'text': text});

    if (response.statusCode != 201) {
      throw Exception('发送消息失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> openChat(String chatId) async {
    final response = await _apiClient.post('/chats/$chatId/open', body: {});

    if (response.statusCode != 200) {
      throw Exception('打开会话失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> togglePinChat(String chatId) async {
    final response = await _apiClient.post('/chats/$chatId/pin', body: {});

    if (response.statusCode != 200) {
      throw Exception('更新会话失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }


  Future<Map<String, dynamic>> chatWithAi({required String prompt}) async {
    final response = await _apiClient.post('/ai/chat', body: {'prompt': prompt});

    if (response.statusCode != 200) {
      throw Exception('AI 对话失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recordTweetView(String tweetId) async {
    final response = await _apiClient.post('/tweets/$tweetId/view', body: {});

    if (response.statusCode != 200) {
      throw Exception('记录浏览失败: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
