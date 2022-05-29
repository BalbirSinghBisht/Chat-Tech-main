import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String name, email, phone,profileimg,status;
bool existence;

Future<void> addUsers(
    String username, String useremail, String userphone, String profileimg,
    String status, List searchString, List searchskill) async {
  return await FirebaseFirestore.instance.collection("users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .set({
    'username': username,
    'email': useremail,
    'phone': userphone,
    'profileimg': profileimg,
    'uid': FirebaseAuth.instance.currentUser.uid,
    'status': status,
    'searchString': searchString,
    'searchSkill' : searchskill
  });
}

Future<void> updateProfilePic(String username, String useremail, String userphone, String profileimg,
    String status, List searchString, List searchskill) async{
  return await FirebaseFirestore.instance.collection("users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .set({
    'username': username,
    'email': useremail,
    'phone': FirebaseAuth.instance.currentUser.phoneNumber,
    'profileimg': profileimg,
    'uid': FirebaseAuth.instance.currentUser.uid,
    'status': status,
    'searchString': searchString,
    'searchSkill' : searchskill
  });
}

Future<void> updateUsers(String username, String useremail, String userphone, String profileimg,
String status, List searchString, List searchskill) async{
  return await FirebaseFirestore.instance.collection("users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .set({
    'username': username,
    'email': useremail,
    'phone': FirebaseAuth.instance.currentUser.phoneNumber,
    'profileimg': profileimg,
    'uid': FirebaseAuth.instance.currentUser.uid,
    'status': status,
    'searchString': searchString,
    'searchSkill' : searchskill
  });
}

Future<void> getUser() async {
  try {
    await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      name = value.get('username');
      email = value.get('email');
      phone = value.get('phone');
      profileimg = value.get('profileimg');
      status = value.get('status');
      existence=value.exists;
      print("yes");
    });
  } catch (e) {
    print(e.toString());
    print("No");
  }
}

Future<Stream<QuerySnapshot>> getUserByUid(String uid) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: uid)
        .snapshots();
}

Future addMessage(
    String chatRoomId, String messageId, Map messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
}

updateLastMessageSend(String chatRoomId, Map lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
}

createChatRoom(String chatRoomId, Map chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      // chatroom already exists
      return true;
    } else {
      // chatroom does not exists
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
}

Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: false)
        .snapshots();
}

Future<Stream<QuerySnapshot>> getTheChatRooms() async {
    String myUid = FirebaseAuth.instance.currentUser.uid;
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs", descending: true)
        .where("users", arrayContains: myUid)
        .snapshots();
}

Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: username)
        .get();
}