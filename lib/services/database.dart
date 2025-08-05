import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod {
  Future addUserInfor(Map<String, dynamic> userInforMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInforMap);
  }

  Future<void> updateUserBalance(String id, int balance) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).update({
      'balance': balance,
    });
  }

  Future<int> getUserBalance(String id) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['balance'] ?? 0;
    } else {
      return 0;
    }
  }
}