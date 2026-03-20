import 'dart:async';

import 'package:get/get.dart';

import '../../data/models/chat_model.dart';
import '../../data/models/community_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/topic_model.dart';
import '../../data/models/tweet_model.dart';
import '../../data/services/tweet_service.dart';

class SocialController extends GetxController {
  SocialController(this._tweetService);

  final TweetService _tweetService;

  final RxList<TopicModel> topics = <TopicModel>[].obs;
  final RxBool topicLoading = false.obs;
  final RxnString topicError = RxnString();
  final RxBool topicCreating = false.obs;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxList<ChatModel> chats = <ChatModel>[].obs;

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
    loadCommunities();
    loadNotifications();
    loadChats();
  }

  Future<void> loadNotifications() async {
    try {
      final items = await _tweetService.fetchNotifications();
      notifications.assignAll(items);
    } catch (_) {
      // 忽略加载失败，保留当前数据
    }
  }

  Future<void> loadChats() async {
    try {
      final items = await _tweetService.fetchChats();
      chats.assignAll(items);
    } catch (_) {
      // 忽略加载失败，保留当前数据
    }
  }

  Future<void> loadSearchTweets() async {
    if (searchQuery.value.trim().isEmpty) {
      searchTweets.clear();
      searchError.value = null;
      searchLoading.value = false;
      return;
    }
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
    if (searchQuery.value.trim().isEmpty) {
      topics.clear();
      topicError.value = null;
      topicLoading.value = false;
      return;
    }
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

  List<NotificationModel> get filteredNotifications {
    if (selectedNotificationFilter.value == 1) {
      return notifications.where((item) => !item.read).toList();
    }
    return notifications;
  }

  Future<void> refreshAll() async {
    await Future.wait([search(), loadCommunities(), loadNotifications(), loadChats()]);
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
    _searchDebounce = Timer(const Duration(milliseconds: 350), search);
  }

  void clearSearchQuery() {
    if (searchQuery.value.isEmpty) {
      return;
    }

    searchQuery.value = '';
    _searchDebounce?.cancel();
    searchTweets.clear();
    topics.clear();
  }

  Future<void> search() async {
    if (searchQuery.value.trim().isEmpty) {
      searchTweets.clear();
      topics.clear();
      searchError.value = null;
      topicError.value = null;
      searchLoading.value = false;
      topicLoading.value = false;
      return;
    }
    await Future.wait([loadSearchTweets(), loadTopics()]);
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

  Future<void> markNotificationRead(NotificationModel item) async {
    final updated = await _tweetService.markNotificationRead(item.id);
    final index = notifications.indexWhere((notification) => notification.id == item.id);
    if (index != -1) {
      notifications[index] = updated;
    }
  }

  Future<void> markAllNotificationsRead() async {
    final updated = await _tweetService.markAllNotificationsRead();
    notifications.assignAll(updated);
  }

  Future<void> openChat(ChatModel item) async {
    final updated = await _tweetService.openChat(item.id);
    final index = chats.indexWhere((chat) => chat.id == item.id);
    if (index != -1) {
      chats[index] = updated;
    }
  }

  Future<void> togglePinChat(ChatModel item) async {
    await _tweetService.togglePinChat(item.id);
    await loadChats();
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
