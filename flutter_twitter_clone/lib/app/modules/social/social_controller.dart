import 'package:get/get.dart';

import '../../data/models/topic_model.dart';
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

class CommunityItem {
  CommunityItem({
    required this.id,
    required this.name,
    required this.members,
    required this.tag,
    this.joined = false,
  });

  final String id;
  final String name;
  int members;
  final String tag;
  bool joined;
}

class SocialController extends GetxController {
  SocialController(this._tweetService);

  final TweetService _tweetService;

  final RxList<TopicModel> topics = <TopicModel>[].obs;
  final RxBool topicLoading = false.obs;

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

  final RxList<CommunityItem> communities = <CommunityItem>[
    CommunityItem(id: 'g1', name: 'Flutter 中文社区', members: 12400, tag: '移动开发'),
    CommunityItem(id: 'g2', name: '前端工程师联盟', members: 9100, tag: 'Web'),
    CommunityItem(id: 'g3', name: '独立开发者日记', members: 7500, tag: '创业'),
    CommunityItem(id: 'g4', name: '产品增长实验室', members: 5300, tag: '增长'),
    CommunityItem(id: 'g5', name: '设计系统研究所', members: 4600, tag: '设计'),
  ].obs;

  final RxString searchQuery = ''.obs;
  final RxInt selectedNotificationFilter = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadTopics();
  }

  Future<void> loadTopics() async {
    try {
      topicLoading.value = true;
      final items = await _tweetService.fetchTopics(query: searchQuery.value.trim());
      topics.assignAll(items);
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
    await loadTopics();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    loadTopics();
  }

  Future<void> toggleTopicFollow(TopicModel topic) async {
    final updated = await _tweetService.updateTopicFollow(topicId: topic.id, active: !topic.following);
    final index = topics.indexWhere((item) => item.id == topic.id);
    if (index != -1) {
      topics[index] = updated;
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

  void joinCommunity(CommunityItem item) {
    item.joined = !item.joined;
    item.members += item.joined ? 1 : -1;
    communities.refresh();
  }
}
