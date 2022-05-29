import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/dashboard.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:chatapp/utils/extensions.dart';
import 'package:chatapp/utils/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class UserDetails extends StatefulWidget {
  final String phone;
  UserDetails({this.phone});
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  File img1;
  String path1 = "";
  TextEditingController username = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController status = new TextEditingController();
  bool isLoading = false;

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
  }

  Future uploadProfileImg() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        'admins/${FirebaseAuth.instance.currentUser.uid}/images/${Path.basename(img1.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(img1);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURLTwo) {
      setState(() {
        path1 = fileURLTwo;
        print(path1);
      });
    });
  }

  List searchString = [];
  List searchskill = [];

  void search(String a) {
    List words = [];
    a += ' ';
    words = a.split(' ');
    for (int k = 0; k < words.length; k++) {
      for (int i = 1; i <= words[k].length; i++) {
        searchString.add(words[k].substring(0, i).trim().toLowerCase());
      }
    }
  }

  void searchSkill(String a) {
    List words = [];
    a += ' ';
    words = a.split(' ');
    for (int k = 0; k < words.length; k++) {
      for (int i = 1; i <= words[k].length; i++) {
        searchskill.add(words[k].substring(0, i).trim().toLowerCase());
      }
    }
  }

  Future<void> loadDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          title: Text('Please wait while we register you'),
          actions: <Widget>[
            Center(
              child: Container(
                child: Theme(
                  data: ThemeData.light(),
                  child: CupertinoActivityIndicator(
                    animating: true,
                    radius: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Colors.transparent);
    final ButtonStyle elevatedButtonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(65.0),
        ),
      ),
      backgroundColor: Colors.grey[200],
      padding: EdgeInsets.all(0),
    );
    return Scaffold(
      backgroundColor: Color(0xFFF8F7F7),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            mTop(context, "Add User"),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 16.0, right: 16.0,
                    top: 8.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // SizedBox(height: 24.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Profile picture',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Ink(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(65.0),
                              ),
                            ),
                            child: img1 == null
                                ? ElevatedButton(
                                    style: elevatedButtonStyle,
                                    onPressed: getProfileImage,
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png',
                                      fit: BoxFit.fill,
                                      alignment: Alignment.center,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: getProfileImage,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(65.0),
                                      ),
                                      child: Image.file(
                                        img1,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Tap to choose profile image")],
                      ),
                      SizedBox(height: 8.0),
                      text("Enter your Details",
                          isLongText: true, isCentered: true),
                      SizedBox(height: 24.0 - 8),
                      Container(
                        decoration: boxDecoration(
                            showShadow: false,
                            bgColor: Color(0xFFF8F7F7),
                            radius: 8,
                            color: Color(0xFFDADADA)),
                        padding: EdgeInsets.all(0),
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Regular'),
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                            hintText: "Username",
                            prefixIcon: Icon(Icons.person),
                            hintStyle: TextStyle(
                                color: Color(0xFF9D9D9D),
                                fontSize: 16.0),
                            border: InputBorder.none,
                          ),
                          controller: username,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Container(
                        decoration: boxDecoration(
                            showShadow: false,
                            bgColor: Color(0xFFF8F7F7),
                            radius: 8,
                            color: Color(0xFFDADADA)),
                        padding: EdgeInsets.all(0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Regular'),
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                            hintText: "Add Skills",
                            prefixIcon: Icon(Icons.info),
                            hintStyle: TextStyle(
                                color: Color(0xFF9D9D9D),
                                fontSize: 16.0),
                            border: InputBorder.none,
                          ),
                          controller: status,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Container(
                        decoration: boxDecoration(
                            showShadow: false,
                            bgColor: Color(0xFFF8F7F7),
                            radius: 8,
                            color: Color(0xFFDADADA)),
                        padding: EdgeInsets.all(0),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'Regular'),
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                            hintText: "Email address",
                            prefixIcon: Icon(Icons.email),
                            hintStyle: TextStyle(
                                color: Color(0xFF9D9D9D),
                                fontSize: 16.0),
                            border: InputBorder.none,
                          ),
                          controller: email,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      SocialAppButton(
                        onPressed: () async {
                          if (img1 != null &&
                              username.text != "" &&
                              email.text != "" &&
                              path1 != "" &&
                              status.text != "") {
                            setState(() {
                              isLoading = true;
                            });
                            if (isLoading) {
                              loadDialog();
                            }
                            await uploadProfileImg();
                            search(username.text);
                            searchSkill(status.text);
                            print(FirebaseAuth.instance.currentUser.uid);
                            Future.delayed(const Duration(seconds: 5),
                                () async {
                              await addUsers(username.text, email.text,
                                  widget.phone, path1, status.text,searchString, searchskill);
                              await getUser();   
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SocialDashboard()),
                                  (route) => false);
                            });
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('Incomplete Information'),
                                      content: Text(
                                          'Please Upload image or Fill all the information'),
                                      actions: [
                                        TextButton(
                                          child: Text('Ok'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                )
                            );
                          }
                        },
                        textContent: "Continue",
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}