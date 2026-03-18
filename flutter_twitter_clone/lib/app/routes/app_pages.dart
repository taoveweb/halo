import 'package:get/get.dart';

import '../modules/compose/compose_view.dart';
import '../modules/home/home_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/tweet_detail/tweet_detail_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
    GetPage(name: AppRoutes.compose, page: () => const ComposeView()),
    GetPage(name: AppRoutes.tweetDetail, page: () => const TweetDetailView()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
  ];
}
