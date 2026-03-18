import 'package:get/get.dart';

import '../modules/auth/auth_view.dart';
import '../modules/communities/communities_view.dart';
import '../modules/compose/compose_view.dart';
import '../modules/home/home_view.dart';
import '../modules/messages/messages_view.dart';
import '../modules/notifications/notifications_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/search/search_view.dart';
import '../modules/tweet_detail/tweet_detail_view.dart';
import 'auth_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.login, page: () => const AuthView()),
    GetPage(name: AppRoutes.home, page: () => const HomeView(), middlewares: [AuthMiddleware()]),
    GetPage(name: AppRoutes.search, page: () => const SearchView(), middlewares: [AuthMiddleware()]),
    GetPage(name: AppRoutes.communities, page: () => const CommunitiesView(), middlewares: [AuthMiddleware()]),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsView(), middlewares: [AuthMiddleware()]),
    GetPage(name: AppRoutes.messages, page: () => const MessagesView(), middlewares: [AuthMiddleware()]),
    GetPage(name: AppRoutes.compose, page: () => const ComposeView(), middlewares: [AuthMiddleware()]),
    GetPage(name: AppRoutes.tweetDetail, page: () => const TweetDetailView(), middlewares: [AuthMiddleware()]),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView(), middlewares: [AuthMiddleware()]),
  ];
}
