import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUser(userData, userId) async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .set(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserInfo(String email) async {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("email", isEqualTo: email)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  instantSearch(String searchField) {
    return FirebaseFirestore.instance
        .collection('Users')
        .where('username',
            isGreaterThanOrEqualTo: searchField.substring(0, 1).toUpperCase())
        .get();
  }

  getMyAllChats(String userId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("usersId", arrayContains: userId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  getReceiverData(String receiverUserId) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .where("userId", isEqualTo: receiverUserId)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addChatRoom(chatRoom, chatRoomId) async {
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoom)
        .catchError((e) {
      print(e);
    });
  }
}
