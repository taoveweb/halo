class ChatModel {
  ChatModel({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
    required this.pinned,
    required this.handle,
    required this.avatar,
    required this.joinedAt,
  });

  final String id;
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final bool pinned;
  final String handle;
  final String avatar;
  final String joinedAt;

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      pinned: json['pinned'] == true,
      handle: json['handle']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      joinedAt: json['joinedAt']?.toString() ?? '',
    );
  }
}
