import 'chat_message_model.dart';

class ChatDetailModel {
  ChatDetailModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatar,
    required this.joinedAt,
    required this.createdDate,
    required this.messages,
  });

  final String id;
  final String name;
  final String handle;
  final String avatar;
  final String joinedAt;
  final String createdDate;
  final List<ChatMessageModel> messages;

  factory ChatDetailModel.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    final rawMessages = (json['messages'] as List<dynamic>? ?? const []);
    return ChatDetailModel(
      id: json['id']?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      handle: user['handle']?.toString() ?? '',
      avatar: user['avatar']?.toString() ?? '',
      joinedAt: user['joinedAt']?.toString() ?? '',
      createdDate: json['createdDate']?.toString() ?? '',
      messages: rawMessages
          .map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
