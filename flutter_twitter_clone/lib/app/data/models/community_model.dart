class CommunityModel {
  CommunityModel({
    required this.id,
    required this.name,
    required this.members,
    required this.tag,
    required this.joined,
  });

  final String id;
  final String name;
  final int members;
  final String tag;
  final bool joined;

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      members: json['members'] as int? ?? 0,
      tag: json['tag'] as String,
      joined: json['joined'] as bool? ?? false,
    );
  }
}
