class ApiConstants {
  // Ganti dengan URL backend kamu
  static const String baseUrl = "https://pam-2026-p9-ifs23050-be.11s23050.online:8080/";

  static const String login = "$baseUrl/auth/login";
  static const String me = "$baseUrl/auth/me";

  static const String usernames = "$baseUrl/usernames";
  static const String generateUsername = "$baseUrl/usernames/generate";

  static const List<String> styles = [
    "gaming",
    "professional",
    "cute",
    "aesthetic",
    "funny",
    "minimalist",
    "fantasy",
    "tech",
  ];

  static const Map<String, String> styleLabels = {
    "gaming": "🎮 Gaming",
    "professional": "💼 Professional",
    "cute": "🌸 Cute",
    "aesthetic": "✨ Aesthetic",
    "funny": "😂 Funny",
    "minimalist": "⬜ Minimalist",
    "fantasy": "🧙 Fantasy",
    "tech": "🖥️ Tech",
  };
}
