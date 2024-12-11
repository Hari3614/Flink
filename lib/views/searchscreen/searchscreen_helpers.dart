import 'package:flutter/material.dart';

class SearchHistoryProvider with ChangeNotifier {
  final List<Map<String, String>> _searchHistory = [];

  List<Map<String, String>> get searchHistory =>
      List.unmodifiable(_searchHistory);

  void addUserToHistory(String username, String avatar) {
    // Avoid duplicates
    _searchHistory.removeWhere((user) => user['username'] == username);
    _searchHistory.insert(0, {'username': username, 'avatar': avatar});

    // Optional: Limit history to 10 entries
    if (_searchHistory.length > 10) {
      _searchHistory.removeLast();
    }
    notifyListeners();
  }

  void removeUserFromHistory(String username) {
    _searchHistory.removeWhere((user) => user['username'] == username);
    notifyListeners();
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }
}
