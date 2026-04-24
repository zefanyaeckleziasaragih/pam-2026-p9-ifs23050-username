class UsernameModel {
  final int id;
  final int userId;
  final String keyword;
  final String style;
  final int total;
  final List<String> usernames;
  final String description;
  final String createdAt;

  UsernameModel({
    required this.id,
    required this.userId,
    required this.keyword,
    required this.style,
    required this.total,
    required this.usernames,
    required this.description,
    required this.createdAt,
  });

  factory UsernameModel.fromJson(Map<String, dynamic> json) {
    return UsernameModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      keyword: json['keyword'] ?? '',
      style: json['style'] ?? '',
      total: json['total'] ?? 0,
      usernames: List<String>.from(json['usernames'] ?? []),
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
