class AuthUserModel {
  AuthUserModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.email,
  });

  final String id;
  final String name;
  final String handle;
  final String email;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      handle: json['handle'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'handle': handle,
      'email': email,
    };
  }
}
