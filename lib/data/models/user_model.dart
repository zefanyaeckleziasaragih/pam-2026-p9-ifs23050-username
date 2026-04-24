class UserModel {
  final int id;
  final String username;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.username,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      isAdmin: json['is_admin'] ?? false,
    );
  }
}
