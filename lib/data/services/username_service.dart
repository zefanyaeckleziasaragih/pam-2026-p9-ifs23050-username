import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class UsernameService {
  static Future<Map<String, dynamic>> getHistory(
      String token, int page) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.usernames}?page=$page&per_page=10"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load history");
    }
  }

  static Future<Map<String, dynamic>> generate(
      String token, String keyword, String style, int total) async {
    final response = await http.post(
      Uri.parse(ApiConstants.generateUsername),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "keyword": keyword,
        "style": style,
        "total": total,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? "Failed to generate usernames");
    }
  }

  static Future<void> delete(String token, int id) async {
    final response = await http.delete(
      Uri.parse("${ApiConstants.usernames}/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete");
    }
  }
}
