import 'dart:async';

import 'package:get/get.dart';

import '../../data/models/community_model.dart';
import '../../data/models/topic_model.dart';
import '../../data/models/tweet_model.dart';
import '../../data/services/tweet_service.dart';

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.minutesAgo,
    this.read = false,
  });

  final String id;
  final String title;
  int minutesAgo;
  bool read;
}

class ChatItem {
  ChatItem({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    this.unreadCount = 0,
    this.pinned = false,
  });

  final String id;
  final String name;
  String message;
  String time;
  int unreadCount;
  bool pinned;
}

class SocialController extends GetxController {
  SocialController(this._tweetService);

  final TweetService _tweetService;

  final RxList<TopicModel> topics = <TopicModel>[].obs;
  final RxBool topicLoading = false.obs;
  final RxnString topicError = RxnString();
  final RxBool topicCreating = false.obs;

  final RxList<NotificationItem> notifications = <NotificationItem>[
    NotificationItem(id: 'n1', title: 'Halo Team 赞了你的动态', minutesAgo: 2),
    NotificationItem(id: 'n2', title: 'Jane Doe 转发了你的动态', minutesAgo: 8),
    NotificationItem(id: 'n3', title: '你关注的人 @dev_tom 发布了新动态', minutesAgo: 22),
    NotificationItem(id: 'n4', title: 'Flutter 中文社区 回复了你', minutesAgo: 60),
    NotificationItem(id: 'n5', title: '你的动态获得了 10 次新点赞', minutesAgo: 120),
    NotificationItem(id: 'n6', title: '@product_amy 关注了你', minutesAgo: 180),
  ].obs;

  final RxList<ChatItem> chats = <ChatItem>[
    ChatItem(id: 'c1', name: 'Jane Doe', message: '首页交互我已经提交 PR 啦。', time: '刚刚', unreadCount: 2),
    ChatItem(id: 'c2', name: 'Halo Team', message: '今晚 8 点上线新版本，记得回归测试。', time: '12:20'),
    ChatItem(id: 'c3', name: 'dev_tom', message: '可以把评论接口也接一下吗？', time: '昨天', unreadCount: 1),
    ChatItem(id: 'c4', name: 'product_amy', message: '下周加上推荐流页面如何？', time: '周二'),
    ChatItem(id: 'c5', name: 'design_lily', message: '我更新了深色主题规范。', time: '周一'),
  ].obs;

  final RxList<CommunityModel> communities = <CommunityModel>[].obs;
  final RxBool communityLoading = false.obs;
  final RxnString communityError = RxnString();
  final RxSet<String> communityUpdating = <String>{}.obs;
  final RxList<TweetModel> searchTweets = <TweetModel>[].obs;
  final RxBool searchLoading = false.obs;
  final RxnString searchError = RxnString();

  final RxString searchQuery = ''.obs;
  final RxInt selectedNotificationFilter = 0.obs;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    loadSearchTweets();
    loadCommunities();
  }

  Future<void> loadSearchTweets() async {
    try {
      searchLoading.value = true;
      searchError.value = null;
      final items = await _tweetService.fetchTimeline(
        feed: 'for_you',
        query: searchQuery.value.trim(),
      );
      searchTweets.assignAll(items);
    } catch (error) {
      searchError.value = error.toString();
    } finally {
      searchLoading.value = false;
    }
  }

  Future<void> loadTopics() async {
    try {
      topicLoading.value = true;
      topicError.value = null;
      final items = await _tweetService.fetchTopics(query: searchQuery.value.trim());
      topics.assignAll(items);
    } catch (error) {
      topicError.value = error.toString();
    } finally {
      topicLoading.value = false;
    }
  }

  List<TopicModel> get filteredTopics => topics;

  List<NotificationItem> get filteredNotifications {
    if (selectedNotificationFilter.value == 1) {
      return notifications.where((item) => !item.read).toList();
    }
    return notifications;
  }

  Future<void> refreshAll() async {
    await Future.wait([loadSearchTweets(), loadCommunities()]);
  }

  Future<void> loadCommunities() async {
    try {
      communityLoading.value = true;
      communityError.value = null;
      final items = await _tweetService.fetchCommunities();
      communities.assignAll(items);
    } catch (error) {
      communityError.value = error.toString();
    } finally {
      communityLoading.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), loadSearchTweets);
  }

  void clearSearchQuery() {
    if (searchQuery.value.isEmpty) {
      return;
    }

    searchQuery.value = '';
    _searchDebounce?.cancel();
    loadSearchTweets();
  }

  Future<void> toggleTopicFollow(TopicModel topic) async {
    final updated = await _tweetService.updateTopicFollow(topicId: topic.id, active: !topic.following);
    final index = topics.indexWhere((item) => item.id == topic.id);
    if (index != -1) {
      topics[index] = updated;
    }
  }

  Future<void> createTopic(String title) async {
    if (topicCreating.value) return;

    final normalized = title.trim();
    if (normalized.isEmpty) return;

    try {
      topicCreating.value = true;
      final created = await _tweetService.createTopic(title: normalized);
      final exists = topics.any((item) => item.id == created.id);
      if (!exists) {
        topics.insert(0, created);
      }
      searchQuery.value = '';
      await loadTopics();
    } finally {
      topicCreating.value = false;
    }
  }

  void setNotificationFilter(int index) {
    selectedNotificationFilter.value = index;
  }

  void markNotificationRead(NotificationItem item) {
    item.read = true;
    notifications.refresh();
  }

  void markAllNotificationsRead() {
    for (final item in notifications) {
      item.read = true;
    }
    notifications.refresh();
  }

  void openChat(ChatItem item) {
    item.unreadCount = 0;
    item.time = '刚刚';
    chats.refresh();
  }

  void togglePinChat(ChatItem item) {
    item.pinned = !item.pinned;
    chats.sort((a, b) {
      if (a.pinned == b.pinned) return 0;
      return a.pinned ? -1 : 1;
    });
  }

  Future<void> joinCommunity(CommunityModel item) async {
    if (communityUpdating.contains(item.id)) {
      return;
    }

    try {
      communityUpdating.add(item.id);
      final updated = await _tweetService.updateCommunityJoin(
        communityId: item.id,
        active: !item.joined,
      );
      final index = communities.indexWhere((community) => community.id == item.id);
      if (index != -1) {
        communities[index] = updated;
      }
    } finally {
      communityUpdating.remove(item.id);
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }
}
