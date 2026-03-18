class TopicModel {
  TopicModel({
    required this.id,
    required this.title,
    required this.posts,
    this.following = false,
  });

  final String id;
  final String title;
  final int posts;
  final bool following;

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String,
      title: json['title'] as String,
      posts: json['posts'] as int? ?? 0,
      following: json['following'] as bool? ?? false,
    );
  }
}
