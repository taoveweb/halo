import '../models/comment_model.dart';
import '../models/community_model.dart';
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

  Future<TweetModel> createTweet(String content) async {
    final data = await _provider.postTweet(content: content);
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
}
