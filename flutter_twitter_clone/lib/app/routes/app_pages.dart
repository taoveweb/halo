import 'package:get/get.dart';

import '../modules/communities/communities_view.dart';
import '../modules/compose/compose_view.dart';
import '../modules/home/home_view.dart';
import '../modules/messages/messages_view.dart';
import '../modules/notifications/notifications_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/search/search_view.dart';
import '../modules/tweet_detail/tweet_detail_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
    GetPage(name: AppRoutes.search, page: () => const SearchView()),
    GetPage(name: AppRoutes.communities, page: () => const CommunitiesView()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsView()),
    GetPage(name: AppRoutes.messages, page: () => const MessagesView()),
    GetPage(name: AppRoutes.compose, page: () => const ComposeView()),
    GetPage(name: AppRoutes.tweetDetail, page: () => const TweetDetailView()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
  ];
}
