import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod{
  Future addUserInfor(Map<String, dynamic> userInforMap, String id) async {
    return await FirebaseFirestore.instance
    .collection("users")
    .doc(id)
    .set(userInforMap);
  }
}