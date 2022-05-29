import 'dart:io';
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

class UpdateProfilePic extends StatefulWidget {
  final String phone;
  UpdateProfilePic({this.phone});
  @override
  _UpdateProfilePicState createState() => _UpdateProfilePicState();
}

class _UpdateProfilePicState extends State<UpdateProfilePic> {
  File img1;
  String path1 = "";
  bool isLoading = false;

  Future getProfileImage() async {
    final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        path1 = pickedFile.path;
        img1 = File(pickedFile.path);
      } else {
        path1 = profileimg;
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
          title: Text('Please wait while we updated your pic'),
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
    var width = MediaQuery.of(context).size.height;
    changeStatusColor(Colors.transparent);
    return Scaffold(
      backgroundColor: Color(0xFFF8F7F7),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            mTop(context, "Update Pic"),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          img1 == null ? Text(
                            'Profile picture',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 25.0,
                            ),
                          ):Text(
                            'New Profile picture',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 25.0,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Ink(
                            height: width * 0.6,
                            width: width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            child: img1 == null
                                ? GestureDetector(
                                  onTap: getProfileImage,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    child: Image.network(
                                      profileimg != null ? profileimg :
                                      "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                                : GestureDetector(
                                  onTap: getProfileImage,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    child: Image.file(
                                      img1,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Tap to choose profile image")],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(10),
              child: SocialAppButton(
                onPressed: () async {
                  if (img1 != null &&
                      path1 != "") {
                    setState(() {
                      email = email.toString();
                      name = name.toString();
                      status = status.toString();
                      isLoading = true;
                    });
                    if (isLoading) {
                      loadDialog();
                    }
                    await uploadProfileImg();
                    search(name);
                    searchSkill(status);
                    print(FirebaseAuth.instance.currentUser.uid);
                    Future.delayed(const Duration(seconds: 5),
                            () async {
                          await updateProfilePic(name, email,
                              widget.phone, path1, status,searchString,searchskill);
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
                              'Please Select Image or Go Back'),
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
                textContent: "Update",
              ),
            ),
          ],
        ),
      ),
    );
  }
}