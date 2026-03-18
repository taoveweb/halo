class CommentModel {
  CommentModel({
    required this.id,
    required this.tweetId,
    required this.author,
    required this.handle,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String tweetId;
  final String author;
  final String handle;
  final String content;
  final DateTime createdAt;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      tweetId: json['tweetId'] as String,
      author: json['author'] as String,
      handle: json['handle'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
