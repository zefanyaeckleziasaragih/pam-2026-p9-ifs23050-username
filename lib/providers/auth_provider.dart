import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? user;
  String? token;
  bool isLoading = false;
  String? errorMessage;

  bool get isAuthenticated => token != null && user != null;

  Future<bool> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.login(username, password);
      token = result['token'];
      user = UserModel.fromJson(result['user']);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    user = null;
    token = null;
    notifyListeners();
  }
}
