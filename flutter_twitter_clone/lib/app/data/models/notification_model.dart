class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.minutesAgo,
    required this.read,
    this.tweetId,
    this.commentId,
  });

  final String id;
  final String title;
  final int minutesAgo;
  final bool read;
  final String? tweetId;
  final String? commentId;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      minutesAgo: (json['minutesAgo'] as num?)?.toInt() ?? 0,
      read: json['read'] == true,
      tweetId: json['tweetId']?.toString(),
      commentId: json['commentId']?.toString(),
    );
  }
}
