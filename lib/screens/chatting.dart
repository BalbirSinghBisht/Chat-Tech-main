import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/dashboard.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/utils/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as Path;

//ignore: must_be_immutable
class SocialChatting extends StatefulWidget {
  String name, uid, phone, image;
  SocialChatting({this.name, this.uid, this.phone, this.image});

  @override
  SocialChattingState createState() => SocialChattingState();
}

class SocialChattingState extends State<SocialChatting> {
  String chatRoomId, messageId = "";
  Stream messageStream;
  File img1;
  String path1 = "";
  TextEditingController chatmessage = TextEditingController();
  ScrollController controller = new ScrollController();
  String encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  //ChatRoomId
  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }
  //Add Image Message Function
  addImageMessage() {
    if (path1 != "") {
      var lastMessageTs = DateTime.now();
      String message = "Image";

      Map<String, dynamic> messageInfoMap = {
        "message": path1,
        "sendBy": FirebaseAuth.instance.currentUser.uid,
        "ts": lastMessageTs,
        "imgUrl": profileimg,
        "type": "image",
        "isRead": false,
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      addMessage(chatRoomId, messageId, messageInfoMap).then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": FirebaseAuth.instance.currentUser.uid,
        };
        messageId = "";
        updateLastMessageSend(chatRoomId, lastMessageInfoMap);
      });
    }
  }
  // Add Video Message Function
  addVideoMessage() {
    if (path1 != "") {
      var lastMessageTs = DateTime.now();
      String message = "Video";

      Map<String, dynamic> messageInfoMap = {
        "message": path1,
        "sendBy": FirebaseAuth.instance.currentUser.uid,
        "ts": lastMessageTs,
        "imgUrl": profileimg,
        "type": "video",
        "isRead": false,
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      addMessage(chatRoomId, messageId, messageInfoMap).then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": FirebaseAuth.instance.currentUser.uid,
        };
        messageId = "";
        updateLastMessageSend(chatRoomId, lastMessageInfoMap);
      });
    }
  }
  //Add Text Message
  addTheMessage() {
    if (chatmessage.text != "") {
      var lastMessageTs = DateTime.now();
      String message = chatmessage.text;

      Map<String, dynamic> messageInfoMap = {
        "message": chatmessage.text,
        "sendBy": FirebaseAuth.instance.currentUser.uid,
        "ts": lastMessageTs,
        "imgUrl": profileimg,
        "type": "message",
        "isRead": false,
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      addMessage(chatRoomId, messageId, messageInfoMap).then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": FirebaseAuth.instance.currentUser.uid,
        };
        messageId = "";
        updateLastMessageSend(chatRoomId, lastMessageInfoMap);
      });
    }
  }

  getAndSetMessages() async {
    messageStream = await getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  //Get Image from Phone
  Future getProfileImage() async {
    final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        path1 = pickedFile.path;
        img1 = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    if (img1 != null) {
      await uploadProfileImg();
    }
  }
  //Upload Image to Server
  Future uploadProfileImg() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        'chats/${FirebaseAuth.instance.currentUser.uid}/images/${Path.basename(img1.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(img1);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURLTwo) {
      setState(() {
        path1 = fileURLTwo;
        print(path1);
        addImageMessage();
        controller.jumpTo(controller.position.maxScrollExtent);
      });
    });
  }
  //Get Video from Phone
  Future getProfileVideo() async {
    PickedFile pickedFile = await ImagePicker().getVideo(
        source: ImageSource.gallery,maxDuration: Duration(minutes: 2));
    setState(() {
      if (pickedFile != null) {
        path1 = pickedFile.path;
        img1 = File(pickedFile.path);
      } else {
        print('No Video selected.');
      }
    });
    if (img1 != null) {
      await uploadProfileVideo();
    }
  }
  //Upload Video to Server
  Future uploadProfileVideo() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        'chats/${FirebaseAuth.instance.currentUser.uid}/videos/${Path.basename(img1.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(img1,StorageMetadata(
      contentType: "video/mp4",contentEncoding: "mp4",
    ));
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURLTwo) {
      setState(() {
        path1 = fileURLTwo;
        print(path1);
        addVideoMessage();
        controller.jumpTo(controller.position.maxScrollExtent);
      });
    });
  }

  @override
  void initState() {
    chatRoomId = getChatRoomIdByUsernames(
        widget.uid, FirebaseAuth.instance.currentUser.uid);
    getAndSetMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    _showPopUpMenu(Offset offset) async {
      final screenSize = MediaQuery.of(context).size;
      double left = offset.dx;
      double top = offset.dy;
      double right = screenSize.width - offset.dx;
      double bottom = screenSize.height - offset.dy;
      //Database Handler Mail ID
      final stuff = EmailThing("Report ${widget.name}\nuid: ${widget.uid}", "balbirbisht560@gmail.com");
      await showMenu<MenuItemType>(
        context: context,
        position: RelativeRect.fromLTRB(left, top, right, bottom),
        items: MenuItemType.values
            .map((MenuItemType menuItemType) =>
            PopupMenuItem<MenuItemType>(
              value: menuItemType,
              child: Text(getMenuItemString(menuItemType)),
            ))
            .toList(),
      ).then((MenuItemType item) {
        if (item == MenuItemType.REPORT) {
          final Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            path: stuff.email,
            query: encodeQueryParameters(<String, String>{'subject': stuff.title}),);
          launch(emailLaunchUri.toString());
        }
      });
    }

    Widget buildChatMessages(String msg, String type, Timestamp time,
        String fromid, String image, bool isRead) {
      var date =
          DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);
      String val = date.hour < 12 ? "AM" : "PM";
      String msgtime =
          date.hour.toString() + " : " + date.minute.toString() + " " + val;
      if (fromid == FirebaseAuth.instance.currentUser.uid) {
        return Container(
          margin: EdgeInsets.only(right: 16.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width * 0.45,
                decoration: BoxDecoration(
                    color: Color(0xFF333333),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
                child: type == 'message'
                    ? text(msg,
                        textColor: Color(0xFFffffff),
                        fontSize: 16.0,
                        fontFamily: 'Medium',
                        isLongText: true)
                    : type == 'image' ? imageMessage(context, msg): videoMessage(context,msg),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.done_all,
                            color: isRead
                                ? Colors.blue:Color(0xFF9D9D9D),
                            size: 16,),
                      ),
                    ),
                    TextSpan(
                        text: msgtime,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFF9D9D9D)
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (fromid != FirebaseAuth.instance.currentUser.uid ) {
        final size = MediaQuery.of(context).size;
        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.image,
                            placeholder: (context, url) => Container(
                              transform:
                                  Matrix4.translationValues(0.0, 0.0, 0.0),
                              child: Container(
                                  width: 60,
                                  height: 60,
                                  child: Center(
                                      child: new CircularProgressIndicator())),
                            ),
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.name),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                              child: Container(
                                constraints:
                                    BoxConstraints(maxWidth: size.width - 150),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      type == 'message' ? 10.0 : 0),
                                  child: Container(
                                      child: type == 'message'
                                          ? Text(
                                              msg,
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )
                                          : type == 'image'? imageMessage(context, msg)
                                          : videoMessage(context, msg)),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 14.0, left: 4),
                              child: Text(
                                msgtime,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    }

    Widget chatMessages() {
      return StreamBuilder(
        stream: messageStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 70, top: 16),
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  controller: controller,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return buildChatMessages(
                        ds.data()["message"],
                        ds.data()["type"],
                        ds.data()["ts"],
                        ds.data()["sendBy"],
                        ds.data()["imageUrl"],
                        ds.data()["isRead"]);
                  },)
              : Center(child: CircularProgressIndicator());
        },
      );
    }

    var mToolbar = Container(
      width: MediaQuery.of(context).size.width,
      height: width * 0.2,
      color: Color(0xFFffffff),
      margin: EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SocialDashboard()));
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: 16.0),
                  width: width * 0.1,
                  height: width * 0.1,
                  decoration: boxDecoration(
                      showShadow: false, bgColor: Colors.blue),
                  child: Icon(Icons.keyboard_arrow_left, color: Color(0xFFffffff)),
                ),
              ),
              SizedBox(width: 10.0),
              GestureDetector(
                onTap: () async{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => Center(
                      child: CustomImage(
                        img: widget.image.isNotEmpty? widget.image
                            : "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png",
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: CachedNetworkImage(
                    imageUrl: widget.image,
                    height: width * 0.1,
                    width: width * 0.1,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  text(widget.name, fontFamily: 'Medium'),
                ],
              )
            ],
          ),
          Row(
            children: <Widget>[
              GestureDetector(
                  child: Container(
                      child: Icon(Icons.more_vert, color: Color(0xFF333333),size: 26)
                  ),
                  onTapDown: (details) {
                    _showPopUpMenu(details.globalPosition);
                  }),
              SizedBox(width: 20,)
            ],
          ),
        ],
      ),
    );

    Future<bool> _onBackPressed() {
      return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SocialDashboard())) ?? false;
    }

    return WillPopScope(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(200),
            child: mToolbar,
          ),
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(image: AssetImage("images/background.jpeg"),fit: BoxFit.fill),
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 20),
                  reverse: true,
                  child: Column(
                    children: <Widget>[
                      chatMessages(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: width,
                    height: MediaQuery.of(context).size.width * 0.15,
                    color: Color(0xFFF8F7F7),
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              getProfileVideo();
                              controller.animateTo(
                                  controller.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeInOut);
                            },
                            child: Icon(Icons.video_collection,
                                color: Color(0xFF747474),size: 30
                            )
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                            onTap: () {
                              getProfileImage();
                              controller.animateTo(
                                  controller.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeInOut);
                            },
                            child: Icon(Icons.image,
                                color: Color(0xFF747474),size: 30
                            )
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Regular'),
                            controller: chatmessage,
                            decoration: InputDecoration(
                                hintText: "Type a message",
                                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                border: InputBorder.none),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            addTheMessage();
                            chatmessage.text = "";
                            controller.animateTo(
                                controller.position.maxScrollExtent,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeInOut);
                          },
                          child: Icon(
                            Icons.send,
                            color: Color(0xFF747474),
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 0),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        onWillPop: _onBackPressed
    );
  }
}

class EmailThing {
  String title;
  String email;

  EmailThing(title, email) {
    this.title = title;
    this.email = email;
  }
}

enum MenuItemType {
  REPORT
}

getMenuItemString(MenuItemType menuItemType) {
  switch (menuItemType) {
    case MenuItemType.REPORT:
      return "Report";
  }
}