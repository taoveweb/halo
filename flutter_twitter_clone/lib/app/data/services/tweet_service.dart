import '../models/chat_detail_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_model.dart';
import '../models/comment_model.dart';
import '../models/community_model.dart';
import '../models/notification_model.dart';
import '../models/topic_model.dart';
import '../models/tweet_model.dart';
import '../providers/tweet_provider.dart';

class TweetService {
  TweetService(this._provider);

  final TweetProvider _provider;

  Future<List<TweetModel>> fetchTimeline({required String feed, String? query}) async {
    final data = await _provider.fetchTimeline(feed: feed, query: query);
    return data
        .map((item) => TweetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TweetModel> createTweet(
    String content, {
    List<Map<String, String>> media = const [],
  }) async {
    final data = await _provider.postTweet(content: content, media: media);
    return TweetModel.fromJson(data);
  }

  Future<TweetModel> fetchTweetById(String tweetId) async {
    final data = await _provider.fetchTweetById(tweetId);
    return TweetModel.fromJson(data);
  }

  Future<TweetModel> likeTweet({required String tweetId, required bool active}) async {
    final data = await _provider.updateTweetInteraction(tweetId: tweetId, action: 'like', active: active);
    return TweetModel.fromJson(data);
  }

  Future<TweetModel> retweetTweet({required String tweetId, required bool active}) async {
    final data =
        await _provider.updateTweetInteraction(tweetId: tweetId, action: 'retweet', active: active);
    return TweetModel.fromJson(data);
  }

  Future<TweetModel> updateTweet({required String tweetId, required String content}) async {
    final data = await _provider.updateTweet(tweetId: tweetId, content: content);
    return TweetModel.fromJson(data);
  }

  Future<void> deleteTweet(String tweetId) {
    return _provider.deleteTweet(tweetId);
  }

  Future<List<CommentModel>> fetchComments(String tweetId) async {
    final data = await _provider.fetchComments(tweetId);
    return data
        .map((item) => CommentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CommentModel> createComment({required String tweetId, required String content}) async {
    final data = await _provider.postComment(tweetId: tweetId, content: content);
    return CommentModel.fromJson(data);
  }

  Future<List<TopicModel>> fetchTopics({String? query}) async {
    final data = await _provider.fetchTopics(query: query);
    return data.map((item) => TopicModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<TopicModel> updateTopicFollow({required String topicId, required bool active}) async {
    final data = await _provider.updateTopicFollow(topicId: topicId, active: active);
    return TopicModel.fromJson(data);
  }

  Future<TopicModel> createTopic({required String title}) async {
    final data = await _provider.createTopic(title: title);
    return TopicModel.fromJson(data);
  }

  Future<List<CommunityModel>> fetchCommunities() async {
    final data = await _provider.fetchCommunities();
    return data.map((item) => CommunityModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<CommunityModel> updateCommunityJoin({
    required String communityId,
    required bool active,
  }) async {
    final data = await _provider.updateCommunityJoin(communityId: communityId, active: active);
    return CommunityModel.fromJson(data);
  }


  Future<List<NotificationModel>> fetchNotifications() async {
    final data = await _provider.fetchNotifications();
    return data.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<NotificationModel> markNotificationRead(String notificationId) async {
    final data = await _provider.markNotificationRead(notificationId);
    return NotificationModel.fromJson(data);
  }

  Future<List<NotificationModel>> markAllNotificationsRead() async {
    final data = await _provider.markAllNotificationsRead();
    return data.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<ChatModel>> fetchChats() async {
    final data = await _provider.fetchChats();
    return data.map((item) => ChatModel.fromJson(item as Map<String, dynamic>)).toList();
  }


  Future<ChatDetailModel> fetchChatDetail(String chatId) async {
    final data = await _provider.fetchChatDetail(chatId);
    return ChatDetailModel.fromJson(data);
  }

  Future<ChatMessageModel> sendChatMessage({
    required String chatId,
    required String text,
  }) async {
    final data = await _provider.sendChatMessage(chatId: chatId, text: text);
    return ChatMessageModel.fromJson(data);
  }

  Future<ChatModel> openChat(String chatId) async {
    final data = await _provider.openChat(chatId);
    return ChatModel.fromJson(data);
  }

  Future<ChatModel> togglePinChat(String chatId) async {
    final data = await _provider.togglePinChat(chatId);
    return ChatModel.fromJson(data);
  }


  Future<String> chatWithAi({required String prompt}) async {
    final data = await _provider.chatWithAi(prompt: prompt);
    return (data['reply'] ?? '').toString();
  }

  Future<TweetModel> recordTweetView(String tweetId) async {
    final data = await _provider.recordTweetView(tweetId);
    return TweetModel.fromJson(data);
  }
}
