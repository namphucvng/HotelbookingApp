import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, Map<String, dynamic>> _favorites = {};

  bool _isEditing = false; // Thêm dòng này

  Map<String, Map<String, dynamic>> get favorites => _favorites;

  bool get isEditing => _isEditing; // Getter cho trạng thái chỉnh sửa

  void toggleEdit() { // Hàm chuyển đổi trạng thái chỉnh sửa
    _isEditing = !_isEditing;
    notifyListeners();
  }

  Future<void> removeFavorite(String roomId) async {
  final user = _auth.currentUser;
  if (user == null) return;

  final ref = _firestore
      .collection('users')
      .doc(user.uid)
      .collection('favorites')
      .doc(roomId);

  await ref.delete();
  _favorites.remove(roomId);

  notifyListeners();
}


  bool isFavorite(String roomId) {
    return _favorites.containsKey(roomId);
  }

  Future<void> loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    _favorites.clear();
    for (var doc in snapshot.docs) {
      _favorites[doc.id] = doc.data();
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String roomId, Map<String, dynamic> roomData) async {
  final user = _auth.currentUser;
  if (user == null) return;

  final favRef = _firestore
      .collection('users')
      .doc(user.uid)
      .collection('favorites') // ✅ dùng "favorites" cho collection con
      .doc(roomId); // ✅ dùng roomId làm document ID

  final doc = await favRef.get();

  if (doc.exists) {
    await favRef.delete();
    _favorites.remove(roomId);
    print('❌ Removed from favorites: $roomId');
  } else {
    await favRef.set(roomData); // ✅ Ghi data
    _favorites[roomId] = roomData;
    print('✅ Added to favorites: $roomId');
  }

  notifyListeners();
}
}
