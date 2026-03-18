import 'package:get/get.dart';

import '../data/providers/tweet_provider.dart';
import '../data/services/tweet_service.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/compose/compose_controller.dart';
import '../modules/home/home_controller.dart';
import '../modules/profile/profile_controller.dart';
import '../modules/social/social_controller.dart';
import '../modules/tweet_detail/tweet_detail_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(TweetProvider.new, fenix: true);
    Get.lazyPut(() => TweetService(Get.find()), fenix: true);
    Get.lazyPut(() => HomeController(Get.find()), fenix: true);
    Get.lazyPut(() => ComposeController(Get.find()), fenix: true);
    Get.lazyPut(() => TweetDetailController(Get.find()), fenix: true);
    Get.lazyPut(AuthController.new, fenix: true);
    Get.lazyPut(() => ProfileController(Get.find()), fenix: true);
    Get.lazyPut(() => SocialController(Get.find()), fenix: true);
  }
}
