import 'package:flutter/material.dart';
import '../data/models/username_model.dart';
import '../data/services/username_service.dart';

class UsernameProvider extends ChangeNotifier {
  List<UsernameModel> history = [];
  int page = 1;
  bool isLoading = false;
  bool isGenerating = false;
  bool hasMore = true;
  String? errorMessage;

  void reset() {
    history = [];
    page = 1;
    hasMore = true;
    errorMessage = null;
  }

  Future<void> fetchHistory(String token) async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      final result = await UsernameService.getHistory(token, page);
      final List data = result['data'];

      if (data.isEmpty) {
        hasMore = false;
      } else {
        history.addAll(data.map((e) => UsernameModel.fromJson(e)).toList());
        page++;
      }
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UsernameModel?> generate(
      String token, String keyword, String style, int total) async {
    isGenerating = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await UsernameService.generate(token, keyword, style, total);
      final model = UsernameModel.fromJson(result['data']);

      reset();
      await fetchHistory(token);

      return model;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      return null;
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> delete(String token, int id) async {
    try {
      await UsernameService.delete(token, id);
      history.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
    }
  }
}
