import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  FavoritesProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoriteList = prefs.getStringList('favorites');
    if (favoriteList != null) {
      _favorites = favoriteList
          .map((roomStr) => jsonDecode(roomStr) as Map<String, dynamic>)
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _favorites.map((room) => jsonEncode(room)).toList();
    await prefs.setStringList('favorites', encoded);
  }

  bool isFavorite(String roomId) {
    return _favorites.any((room) => room['roomId'].toString() == roomId);
  }

  void toggleFavorite(Map<String, dynamic> roomData) async {
    final roomId = roomData['roomId'].toString();
    final exists = isFavorite(roomId);

    if (exists) {
      _favorites.removeWhere((room) => room['roomId'].toString() == roomId);
    } else {
      _favorites.add(roomData);
    }

    await _saveFavorites();
    notifyListeners();
  }
}
