class TweetModel {
  TweetModel({
    required this.id,
    required this.author,
    required this.handle,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.retweets = 0,
    this.avatarUrl,
  });

  final String id;
  final String author;
  final String handle;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int retweets;
  final String? avatarUrl;

  factory TweetModel.fromJson(Map<String, dynamic> json) {
    return TweetModel(
      id: json['id'] as String,
      author: json['author'] as String,
      handle: json['handle'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      retweets: json['retweets'] as int? ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'handle': handle,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'retweets': retweets,
      'avatarUrl': avatarUrl,
    };
  }
}
