import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/chatting.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:chatapp/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SocialHomeChats extends StatefulWidget {
  @override
  SocialHomeChatsState createState() => SocialHomeChatsState();
}

class SocialHomeChatsState extends State<SocialHomeChats> {
  Stream usersStream, chatRoomsStream;

  getChatRoomIdByUid(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  getChatRooms() async {
    chatRoomsStream = await getTheChatRooms();
    setState(() {});
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("${snapshot.error}");
          return Text('We got an Error ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: Container(
                child: Theme(
                  data: ThemeData.light(),
                  child: CupertinoActivityIndicator(
                    animating: true,
                    radius: 20,
                  ),
                ),
              ),
            );

          case ConnectionState.none:
            return Text('oops no data');

          case ConnectionState.done:
            return Text('We are Done');
          default:
            return Container(
              decoration: boxDecoration(radius: 10.0),
              padding: EdgeInsets.all(10.0),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (context, index) {
                    DocumentSnapshot chatlist = snapshot.data.docs[index];
                    print(snapshot.data.docs[index].id);
                    return Chats(
                      lastMessage: chatlist.data()["lastMessage"],
                      chatRoomId: chatlist.id,
                      myUsername: FirebaseAuth.instance.currentUser.uid,
                      time: chatlist.data()["lastMessageSendTs"],
                    );
                  }),
            );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getChatRooms();
  }

  var mFriendsLabel = text("Recent Chats", fontFamily: 'Medium');

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              mFriendsLabel,
              SizedBox(
                height: 16.0,
              ),
              Column(
                children: [
                  chatRoomsList(),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
class Chats extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  Timestamp time;
  Chats({this.lastMessage, this.chatRoomId, this.myUsername, this.time});

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  String profilePicUrl = "", name = "", username = "", phone = "";
  String val="",msgtime="";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await getUserInfo(username);
    print(
        "Id: ${querySnapshot.docs[0].id} \nUserName: ${querySnapshot.docs[0]["username"]} "
            "\nProfile: ${querySnapshot.docs[0]["profileimg"]}");
    name = "${querySnapshot.docs[0]["username"]}";
    profilePicUrl = "${querySnapshot.docs[0]["profileimg"]}";
    phone = "${querySnapshot.docs[0]["phone"]}";
    setState(() {});
  }

  @override
  void initState() {
    var date = DateTime.fromMillisecondsSinceEpoch(widget.time.millisecondsSinceEpoch);    
    val=date.hour<12?"AM":"PM";
    msgtime=date.hour.toString()+" : "+date.minute.toString()+" "+val;
    print(widget.time.toString()+"  "+msgtime);
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SocialChatting(
                      name: name,
                      uid: username,
                      phone: phone,
                      image: profilePicUrl,
                    )));
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16.0),
        shadowColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => Center(
                          child: CustomImage(
                            img: profilePicUrl.isNotEmpty? profilePicUrl
                                : "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png",
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                        borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                        child: Container(
                          color: Color(0xFF475062),
                          child: CachedNetworkImage(
                            imageUrl: profilePicUrl.isNotEmpty? profilePicUrl
                                : "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png", ///add image
                            height: width * 0.13,
                            width: width * 0.13,
                            fit: BoxFit.cover,
                          ),
                        )
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        text(name, fontFamily: 'Medium'),

                        ///add name
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Icon(
                                    Icons.done_all,
                                    color: Color(0xFF9D9D9D),
                                    size: 16,
                                  ),
                                ),
                              ),
                              TextSpan(
                                  text: widget.lastMessage.length>15?widget.lastMessage.substring(0,15)+"...":widget.lastMessage,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFF9D9D9D))
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 8.0),
            text(msgtime.toString(),
                fontFamily: 'Medium', fontSize: 14.0),
            /// last msg time
          ],
        ),
      ),
    );
  }
}
