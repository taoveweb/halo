import 'package:get/get.dart';

import '../../data/models/tweet_model.dart';
import '../../data/services/tweet_service.dart';

class HomeController extends GetxController {
  HomeController(this._tweetService);

  final TweetService _tweetService;

  final RxList<TweetModel> tweets = <TweetModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString selectedFeed = 'for_you'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTimeline();
  }

  Future<void> loadTimeline() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await _tweetService.fetchTimeline(feed: selectedFeed.value);
      tweets.assignAll(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> switchFeed(String feed) async {
    if (selectedFeed.value == feed) return;
    selectedFeed.value = feed;
    await loadTimeline();
  }

  Future<void> toggleLike(TweetModel tweet) async {
    final updated = await _tweetService.likeTweet(tweetId: tweet.id, active: !tweet.isLiked);
    _replaceTweet(updated);
  }

  Future<void> toggleRetweet(TweetModel tweet) async {
    final updated = await _tweetService.retweetTweet(tweetId: tweet.id, active: !tweet.isRetweeted);
    _replaceTweet(updated);
  }

  void _replaceTweet(TweetModel updated) {
    final index = tweets.indexWhere((item) => item.id == updated.id);
    if (index != -1) {
      tweets[index] = updated;
    }
  }
}
