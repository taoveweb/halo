import 'package:get/get.dart';

import '../data/providers/tweet_provider.dart';
import '../data/services/tweet_service.dart';
import '../modules/compose/compose_controller.dart';
import '../modules/home/home_controller.dart';
import '../modules/profile/profile_controller.dart';
import '../modules/tweet_detail/tweet_detail_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(TweetProvider.new, fenix: true);
    Get.lazyPut(() => TweetService(Get.find()), fenix: true);
    Get.lazyPut(() => HomeController(Get.find()), fenix: true);
    Get.lazyPut(() => ComposeController(Get.find()), fenix: true);
    Get.lazyPut(TweetDetailController.new, fenix: true);
    Get.lazyPut(ProfileController.new, fenix: true);
  }
}
