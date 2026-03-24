class ChatMessageModel {
  ChatMessageModel({
    required this.id,
    required this.direction,
    required this.text,
    required this.time,
  });

  final String id;
  final String direction;
  final String text;
  final String time;

  bool get isOutbound => direction == 'outbound';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      direction: json['direction']?.toString() ?? 'inbound',
      text: json['text']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}
