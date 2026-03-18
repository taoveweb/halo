import '../models/tweet_model.dart';
import '../providers/tweet_provider.dart';

class TweetService {
  TweetService(this._provider);

  final TweetProvider _provider;

  Future<List<TweetModel>> fetchTimeline() async {
    final data = await _provider.fetchTimeline();
    return data
        .map((item) => TweetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TweetModel> createTweet(String content) async {
    final data = await _provider.postTweet(content: content);
    return TweetModel.fromJson(data);
  }
}
