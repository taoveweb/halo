import 'package:get/get.dart';

import '../../data/models/tweet_model.dart';

class TweetDetailController extends GetxController {
  final Rxn<TweetModel> tweet = Rxn<TweetModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TweetModel) {
      tweet.value = args;
    }
  }
}
