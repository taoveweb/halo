class TweetMediaModel {
  TweetMediaModel({
    required this.id,
    required this.mediaType,
    required this.mediaUrl,
    required this.mimeType,
    required this.sortOrder,
  });

  final String id;
  final String mediaType;
  final String mediaUrl;
  final String mimeType;
  final int sortOrder;

  bool get isVideo => mediaType == 'video';

  factory TweetMediaModel.fromJson(Map<String, dynamic> json) {
    return TweetMediaModel(
      id: json['id'] as String,
      mediaType: json['mediaType'] as String,
      mediaUrl: json['mediaUrl'] as String,
      mimeType: json['mimeType'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'mimeType': mimeType,
      'sortOrder': sortOrder,
    };
  }
}

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
    this.isLiked = false,
    this.isRetweeted = false,
    this.avatarUrl,
    this.media = const [],
  });

  final String id;
  final String author;
  final String handle;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int retweets;
  final bool isLiked;
  final bool isRetweeted;
  final String? avatarUrl;
  final List<TweetMediaModel> media;

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
      isLiked: json['isLiked'] as bool? ?? false,
      isRetweeted: json['isRetweeted'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      media: (json['media'] as List<dynamic>? ?? const [])
          .map((item) => TweetMediaModel.fromJson(item as Map<String, dynamic>))
          .toList(),
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
      'isLiked': isLiked,
      'isRetweeted': isRetweeted,
      'avatarUrl': avatarUrl,
      'media': media.map((item) => item.toJson()).toList(),
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
    bool? isLiked,
    bool? isRetweeted,
    String? avatarUrl,
    List<TweetMediaModel>? media,
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
      isLiked: isLiked ?? this.isLiked,
      isRetweeted: isRetweeted ?? this.isRetweeted,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      media: media ?? this.media,
    );
  }
}
