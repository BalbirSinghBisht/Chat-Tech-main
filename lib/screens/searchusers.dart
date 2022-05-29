import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/chatting.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:chatapp/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  String searchString;
  String searchskill;

  TextEditingController textEditingController = TextEditingController();

  getChatRoomIdByUid(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8f8f8),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          new TextEditingController().clear();
        },
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: boxDecorations(
                          radius: 6,
                          bgColor: Color(0xFFDADADA).withOpacity(0.8),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              searchString = val;
                              searchskill = val;
                            });
                          },
                          controller: textEditingController,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          "Cancel",
                          style:
                              primaryTextStyle1(textColor: Color(0xFF3281FF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Text(
                    "Search for your Favourites",
                    style: secondaryTextStyle(),
                  )),
              SizedBox(
                height: 10,
              ),
              Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                    stream: (searchString == null || searchString.trim() == '')
                        ?(searchskill == null || searchskill.trim() == '')
                      ? FirebaseFirestore.instance
                          .collection("users")
                          .where("uid",
                              isNotEqualTo:
                                  FirebaseAuth.instance.currentUser.uid)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection("users")
                          .where('searchString',
                              arrayContains: searchString.toLowerCase())
                          .snapshots() : FirebaseFirestore.instance
                        .collection("users")
                        .where('searchSkill',
                        arrayContains: searchskill.toLowerCase())
                        .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
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
                          decoration: boxDecoration(radius: 15.0),
                          padding: EdgeInsets.only(bottom: 10),
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.docs.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                DocumentSnapshot chatlist =
                                    snapshot.data.docs[index];
                                print(snapshot.data.docs[index].id);
                                return Padding(
                                  padding: const EdgeInsets.only(left:10,bottom: 5),
                                  child: Chats(
                                    name: chatlist.data()['username'],
                                    status: chatlist.data()['status'],
                                    img: chatlist.data()['profileimg'],
                                    uid: chatlist.data()['uid'],
                                    phn: chatlist.data()['phone'],
                                  ),
                                );
                              }
                          ),
                        );
                    }
                  },
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
class Chats extends StatefulWidget {
  String name, status, img, uid, phn;

  Chats({this.name, this.status, this.img, this.uid, this.phn});

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        var chatRoomId = getChatRoomIdByUsernames(
            FirebaseAuth.instance.currentUser.uid, widget.uid);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [FirebaseAuth.instance.currentUser.uid, widget.uid]
        };
        await createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SocialChatting(
                    name: widget.name, uid: widget.uid, phone: widget.phn,image: widget.img,)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Card(
                shadowColor: Colors.transparent,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => CustomImage(
                            img: widget.img,
                          ),
                        );
                      },
                      child: ClipRRect(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          child: Container(
                            color: Color(0xFF475062),
                            child: CachedNetworkImage(
                              imageUrl: widget.img, ///add image
                              height: width * 0.13,
                              width: width * 0.13,
                              fit: BoxFit.cover,
                            ),
                          )),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                              widget.name,
                              fontFamily: 'Medium'
                          ),
                          text(
                            widget.status,
                            textColor: Color(0xFF9D9D9D),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.0), // last msg time
          ],
        ),
      ),
    );
  }
}
