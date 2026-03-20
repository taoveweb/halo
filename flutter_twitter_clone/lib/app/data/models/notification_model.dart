class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.minutesAgo,
    required this.read,
  });

  final String id;
  final String title;
  final int minutesAgo;
  final bool read;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      minutesAgo: (json['minutesAgo'] as num?)?.toInt() ?? 0,
      read: json['read'] == true,
    );
  }
}
