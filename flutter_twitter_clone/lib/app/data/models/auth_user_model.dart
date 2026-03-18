class AuthUserModel {
  AuthUserModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String handle;
  final String email;
  final String? avatarUrl;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      handle: json['handle'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'handle': handle,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  AuthUserModel copyWith({
    String? id,
    String? name,
    String? handle,
    String? email,
    String? avatarUrl,
    bool clearAvatar = false,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      email: email ?? this.email,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
    );
  }
}
