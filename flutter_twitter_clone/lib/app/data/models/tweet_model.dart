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
    this.views = 0,
    this.isLiked = false,
    this.isRetweeted = false,
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
  final int views;
  final bool isLiked;
  final bool isRetweeted;
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
      views: json['views'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isRetweeted: json['isRetweeted'] as bool? ?? false,
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
      'views': views,
      'isLiked': isLiked,
      'isRetweeted': isRetweeted,
      'avatarUrl': avatarUrl,
    };
  }

  TweetModel copyWith({
    String? id,
    String? author,
    String? handle,
    String? content,
    DateTime? createdAt,
    int? likes,
    int? comments,
    int? retweets,
    int? views,
    bool? isLiked,
    bool? isRetweeted,
    String? avatarUrl,
  }) {
    return TweetModel(
      id: id ?? this.id,
      author: author ?? this.author,
      handle: handle ?? this.handle,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      retweets: retweets ?? this.retweets,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      isRetweeted: isRetweeted ?? this.isRetweeted,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
