import 'package:get/get.dart';

import '../../data/models/tweet_model.dart';
import '../../data/services/tweet_service.dart';

class HomeController extends GetxController {
  HomeController(this._tweetService);

  final TweetService _tweetService;

  final RxList<TweetModel> tweets = <TweetModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTimeline();
  }

  Future<void> loadTimeline() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await _tweetService.fetchTimeline();
      tweets.assignAll(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
