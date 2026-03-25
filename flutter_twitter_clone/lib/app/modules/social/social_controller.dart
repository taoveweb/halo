import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import '../../data/models/chat_detail_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/community_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/topic_model.dart';
import '../../data/models/tweet_model.dart';
import '../../data/services/tweet_service.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/api_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../auth/auth_controller.dart';

class AiChatMessage {
  AiChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class SocialController extends GetxController {
  SocialController(this._tweetService);

  final TweetService _tweetService;

  final RxList<TopicModel> topics = <TopicModel>[].obs;
  final RxBool topicLoading = false.obs;
  final RxnString topicError = RxnString();
  final RxBool topicCreating = false.obs;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadNotificationCount = 0.obs;
  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final Rxn<ChatDetailModel> activeChatDetail = Rxn<ChatDetailModel>();
  final RxBool chatDetailLoading = false.obs;

  final RxList<CommunityModel> communities = <CommunityModel>[].obs;
  final RxBool communityLoading = false.obs;
  final RxnString communityError = RxnString();
  final RxSet<String> communityUpdating = <String>{}.obs;
  final RxList<TweetModel> searchTweets = <TweetModel>[].obs;

  final RxList<AiChatMessage> aiMessages = <AiChatMessage>[
    AiChatMessage(text: '你好，我是 Halo AI 助手，有什么我可以帮你？', isUser: false),
  ].obs;
  final RxBool aiSending = false.obs;
  final RxnString aiError = RxnString();

  final RxBool searchLoading = false.obs;
  final RxnString searchError = RxnString();

  final RxString searchQuery = ''.obs;
  final RxInt selectedNotificationFilter = 0.obs;
  Timer? _searchDebounce;
  Timer? _notificationPollTimer;
  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSub;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final AuthController _auth = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    loadCommunities();
    loadNotifications();
    loadChats();
    // poll notifications periodically so unread count updates in near real-time
    _notificationPollTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      await loadNotifications();
    });
    // attempt websocket connection for real-time notifications
    _setupWebsocket();
    // reconnect when user session changes
    ever(_auth.currentUser, (_) {
      _setupWebsocket();
    });
  }

  void _setupWebsocket() {
    _disconnectWebsocket();
    _connectWebsocket();
  }

  void _connectWebsocket() {
    print('object-----');
    final user = _auth.currentUser.value;
    if (user == null || user.handle == null || user.handle!.isEmpty) return;
    final handle = user.handle!;

    try {
      final api = Uri.parse(ApiConstants.baseUrl);
      final wsScheme = api.scheme == 'https' ? 'wss' : 'ws';
      final uri = Uri(scheme: wsScheme, host: api.host, port: api.hasPort ? api.port : null, path: '/ws/notifications', queryParameters: {'handle': handle});

      _wsChannel = WebSocketChannel.connect(uri);
      _wsSub = _wsChannel!.stream.listen(_onWsMessage, onDone: _onWsDone, onError: _onWsError, cancelOnError: true);
      _reconnectAttempts = 0;
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _disconnectWebsocket() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _wsSub?.cancel();
    _wsSub = null;
    try {
      _wsChannel?.sink.close();
    } catch (_) {}
    _wsChannel = null;
  }

  void _onWsMessage(dynamic raw) {
    try {
      print('Received WS message: $raw');
      final Map<String, dynamic> payload = jsonDecode(raw as String) as Map<String, dynamic>;
      if (payload['type'] == 'notification' && payload['notification'] != null) {
        final notif = payload['notification'] as Map<String, dynamic>;
        final model = NotificationModel.fromJson(notif);
        final exists = notifications.any((n) => n.id == model.id);
        if (!exists) {
          notifications.insert(0, model);
          if (!model.read) unreadNotificationCount.value = unreadNotificationCount.value + 1;
        }
      }
    } catch (_) {
      // ignore malformed messages
    }
  }

  void _onWsDone() {
    print('WS connection closed');
    _scheduleReconnect();
  }

  void _onWsError(error) {
    print('WS error: $error');
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectAttempts += 1;
    final delay = Duration(seconds: (_reconnectAttempts * 2).clamp(2, 30));
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _connectWebsocket();
    });
  }

  Future<void> loadNotifications() async {
    try {
      final items = await _tweetService.fetchNotifications();
      notifications.assignAll(items);
      unreadNotificationCount.value = notifications.where((n) => !n.read).length;
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
    final index = notifications.indexWhere((notification) => notification.id == item.id);
    try {
      final updated = await _tweetService.markNotificationRead(item.id);
      if (index != -1) {
        notifications[index] = updated;
      }
    } catch (_) {
      // fallback: mark local copy as read so UI updates immediately
      if (index != -1) {
        final copy = notifications[index];
        notifications[index] = NotificationModel(
          id: copy.id,
          title: copy.title,
          minutesAgo: copy.minutesAgo,
          read: true,
          tweetId: copy.tweetId,
          commentId: copy.commentId,
        );
      }
    } finally {
      unreadNotificationCount.value = notifications.where((n) => !n.read).length;
    }
  }

  Future<void> markAllNotificationsRead() async {
    final updated = await _tweetService.markAllNotificationsRead();
    notifications.assignAll(updated);
    unreadNotificationCount.value = notifications.where((n) => !n.read).length;
  }

  Future<void> openNotification(NotificationModel item) async {
    final index = notifications.indexWhere((notification) => notification.id == item.id);
    NotificationModel? updated;
    try {
      updated = await _tweetService.markNotificationRead(item.id);
      if (index != -1 && updated != null) {
        notifications[index] = updated;
      }
    } catch (_) {
      // fallback local mark as read
      if (index != -1) {
        final copy = notifications[index];
        notifications[index] = NotificationModel(
          id: copy.id,
          title: copy.title,
          minutesAgo: copy.minutesAgo,
          read: true,
          tweetId: copy.tweetId,
          commentId: copy.commentId,
        );
        updated = notifications[index];
      }
    } finally {
      unreadNotificationCount.value = notifications.where((n) => !n.read).length;
    }

    final targetTweetId = updated?.tweetId;
    final targetCommentId = updated?.commentId;
    if (targetTweetId != null && targetTweetId.isNotEmpty) {
      try {
        final tweet = await _tweetService.fetchTweetById(targetTweetId);
        Get.toNamed(AppRoutes.tweetDetail, arguments: {'tweet': tweet, 'commentId': targetCommentId});
      } catch (_) {
        // ignore navigation failure
      }
    }
  }

  Future<void> openChat(ChatModel item) async {
    final updated = await _tweetService.openChat(item.id);
    final index = chats.indexWhere((chat) => chat.id == item.id);
    if (index != -1) {
      chats[index] = updated;
    }
  }

  Future<void> openChatDetail(ChatModel item) async {
    await openChat(item);
    Get.toNamed(AppRoutes.messageDetail, arguments: {'chat': item});
  }

  Future<void> loadChatDetail(String chatId) async {
    try {
      chatDetailLoading.value = true;
      final detail = await _tweetService.fetchChatDetail(chatId);
      activeChatDetail.value = detail;
    } finally {
      chatDetailLoading.value = false;
    }
  }

  Future<void> sendMessage(String chatId, String text) async {
    final content = text.trim();
    if (content.isEmpty) return;
    final message = await _tweetService.sendChatMessage(chatId: chatId, text: content);
    final detail = activeChatDetail.value;
    if (detail != null && detail.id == chatId) {
      activeChatDetail.value = ChatDetailModel(
        id: detail.id,
        name: detail.name,
        handle: detail.handle,
        avatar: detail.avatar,
        joinedAt: detail.joinedAt,
        createdDate: detail.createdDate,
        messages: [...detail.messages, message],
      );
    }
    await loadChats();
  }

  Future<void> togglePinChat(ChatModel item) async {
    await _tweetService.togglePinChat(item.id);
    await loadChats();
  }


  Future<void> askAi(String prompt) async {
    final content = prompt.trim();
    if (content.isEmpty || aiSending.value) {
      return;
    }

    aiError.value = null;
    aiMessages.add(AiChatMessage(text: content, isUser: true));
    aiSending.value = true;

    try {
      final reply = await _tweetService.chatWithAi(prompt: content);
      aiMessages.add(
        AiChatMessage(
          text: reply.isEmpty ? '收到啦，不过我暂时没有生成内容。' : reply,
          isUser: false,
        ),
      );
    } catch (error) {
      aiError.value = error.toString();
      aiMessages.add(
        AiChatMessage(
          text: '抱歉，我刚刚开小差了，请稍后重试。',
          isUser: false,
        ),
      );
    } finally {
      aiSending.value = false;
    }
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
    _notificationPollTimer?.cancel();
    _disconnectWebsocket();
    super.onClose();
  }
}
