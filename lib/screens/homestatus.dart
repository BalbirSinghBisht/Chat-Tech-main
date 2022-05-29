import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/storypage.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:chatapp/utils/dashedcircle.dart';
import 'package:chatapp/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class SocialHomeStatus extends StatefulWidget {
  @override
  SocialHomeStatusState createState() => SocialHomeStatusState();
}

class SocialHomeStatusState extends State<SocialHomeStatus> {
  var mMyStatusLabel = text("MY Status", fontFamily: 'Medium');
  var mFriendsLabel = text("Friends", fontFamily: 'Medium');
  var val = DateTime.now().hour < 12 ? "AM" : "PM";

  File img1;
  String path1 = "";

  Future getProfileImage() async {
    final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        path1 = pickedFile.path;
        img1 = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    if (img1 != null) {
      await uploadProfileImg();
    }
    else {
      print('No image selected.');
    }
  }

  Future uploadProfileImg() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        'status/${FirebaseAuth.instance.currentUser.uid}/images/${Path.basename(img1.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(img1);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURLTwo) {
      setState(() {
        path1 = fileURLTwo;
        print(path1);
        addStatus();
      });
    });
  }

  Future<void> addStatus() async {
    await FirebaseFirestore.instance
        .collection('status')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({
          'name': name,
          'profileimg': profileimg,
          'passimage': path1,
          'time': DateTime.now()
        });
  }

  Widget mStatus() {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        getProfileImage();
      },
      child: Container(
        decoration: boxDecoration(radius: 10.0),
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      child: CachedNetworkImage(
                          imageUrl: profileimg,
                          height: width * 0.13,
                          width: width * 0.13,
                          fit: BoxFit.cover),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0)),
                          color: Color(0xFF494FFB)),
                      child: Icon(Icons.add, color: Color(0xFFffffff), size: 20),
                    )
                  ],
                ),
                SizedBox(
                  width: 10.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    text("My Status", fontFamily: 'Medium'),
                    text(
                      "Tap to add status",
                      textColor: Color(0xFF9D9D9D),
                    )
                  ],
                ),
              ],
            ),
            text(
                DateTime.now().hour.toString() +
                    ":" +
                    DateTime.now().minute.toString() +
                    " " +
                    val,
                fontFamily: 'Medium',
                fontSize: 14.0),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              mMyStatusLabel,
              SizedBox(
                height: 16.0,
              ),
              mStatus(),
              SizedBox(
                height: 16.0,
              ),
              mFriendsLabel,
              SizedBox(
                height: 16.0,
              ),
              Column(
                children: [
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('status')
                          .where("name", isNotEqualTo: name).snapshots(),
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
                              decoration: boxDecoration(showShadow: true),
                              padding: EdgeInsets.all(16.0),
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.docs.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot statuslist =
                                        snapshot.data.docs[index];
                                    print(snapshot.data.docs[index].id);
                                    return Friends(
                                      name: statuslist.data()['name'],
                                      image: statuslist.data()['profileimg'],
                                      passimage: statuslist.data()['passimage'],
                                      time: statuslist.data()['time'],
                                    );
                                  },
                              ),
                            );
                        }
                      },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
class Friends extends StatefulWidget {
  String name, image, passimage;
  Timestamp time;

  Friends({this.name, this.image, this.passimage, this.time});

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  var val = "", msgtime = "";
  @override
  void initState() {
    var date =
        DateTime.fromMillisecondsSinceEpoch(widget.time.millisecondsSinceEpoch);
    val = date.hour < 12 ? "AM" : "PM";
    msgtime = date.day.toString() +"/"+ date.month.toString() +"/"+ date.year.toString();//date.hour.toString() + " : " + date.minute.toString() + " " + val;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var date =
        DateTime.fromMillisecondsSinceEpoch(widget.time.millisecondsSinceEpoch);
    msgtime = date.day.toString() +"/"+ date.month.toString() +"/"+ date.year.toString();
    var width = MediaQuery.of(context).size.width;
    var today = DateTime.now();
    var msgtoday = today.day.toString() +"/"+ today.month.toString() +"/"+ today.year.toString();
    return msgtime == msgtoday ?
    GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoryPageView(
                      image: widget.passimage,
                ),
            )
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 12.0),
        shadowColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                DashedCircle(
                  dashes: 1,
                  child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircleAvatar(
                        radius: 15.0,
                        child: Container(
                          color: Color(0xFFffffff),
                          child: CachedNetworkImage(
                            imageUrl: widget.image,
                            ///add image
                            height: width * 0.2,
                            width: width * 0.2,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                  color: Color(0xFF494FFB),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    text(widget.name, fontFamily: 'Medium'),
                    ///add name
                  ],
                ),
              ],
            ),
            text(msgtime, //add time
                fontFamily: 'Medium',
                fontSize: 14.0),
          ],
        ),
      ),
    ):Container();
  }
}
