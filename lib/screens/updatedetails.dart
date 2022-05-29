import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/dashboard.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:chatapp/utils/extensions.dart';
import 'package:chatapp/utils/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpdateDetails extends StatefulWidget {
  final String phone;
  UpdateDetails({this.phone});
  @override
  _UpdateDetailsState createState() => _UpdateDetailsState();
}

class _UpdateDetailsState extends State<UpdateDetails> {

  String path1 = "";
  TextEditingController username = new TextEditingController();
  TextEditingController userstatus = new TextEditingController();
  bool isLoading = false;

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
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFFF8F7F7),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            mTop(context, "Update User"),
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
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async{
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => Center(
                                  child: CustomImage(
                                    img: profileimg.isNotEmpty? profileimg
                                        : "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png",
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              child: CachedNetworkImage(
                                imageUrl: profileimg,
                                height: width * 0.3,
                                width: width * 0.3,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(height: 8.0),
                      text("Enter your Update Details",
                          isLongText: true, isCentered: true),
                      SizedBox(height: 24.0 - 8),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(8.0, 16, 8.0, 16),
                          decoration: boxDecoration(showShadow: false, bgColor: Colors.grey.shade200),
                          child: Row(
                            children: [
                              SizedBox(width: 5,),
                              Icon(Icons.person,color: Color(0xFF333333),),
                              SizedBox(width: 10,),
                              Text(name,
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 16.0,
                                  )
                              )
                            ],
                          )
                      ),
                      /*Container(
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
                            hintText: name.toString(),
                            prefixIcon: Icon(Icons.person),
                            hintStyle: TextStyle(
                                color: Color(0xFF9D9D9D),
                                fontSize: 16.0),
                            border: InputBorder.none,
                          ),
                          controller: username,
                        ),
                      ),*/
                      SizedBox(height: 24.0),
                      Container(
                        decoration: boxDecoration(
                            showShadow: false,
                            bgColor: Colors.white,
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
                            hintText: status.toString(),
                            prefixIcon: Icon(Icons.info),
                            hintStyle: TextStyle(
                                color: Color(0xFF9D9D9D),
                                fontSize: 16.0),
                            border: InputBorder.none,
                          ),
                          controller: userstatus,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(8.0, 16, 8.0, 16),
                        decoration: boxDecoration(showShadow: false, bgColor: Colors.grey.shade200),
                        child: Row(
                          children: [
                            SizedBox(width: 5,),
                            Icon(Icons.email,color: Color(0xFF333333),),
                            SizedBox(width: 10,),
                            Text(email,
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 16.0,
                                )
                            )
                          ],
                        )
                      ),
                      SizedBox(height: 24.0),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(8.0, 16, 8.0, 16),
                          decoration: boxDecoration(showShadow: false, bgColor: Colors.grey.shade200),
                          child: Row(
                            children: [
                              SizedBox(width: 5,),
                              Icon(Icons.phone,color: Color(0xFF333333),),
                              SizedBox(width: 10,),
                              Text(FirebaseAuth.instance.currentUser.phoneNumber,
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 16.0,
                                  )
                              )
                            ],
                          )
                      ),
                      SizedBox(height: 24.0),
                      SocialAppButton(
                        onPressed: () async {
                          if (email != "") {
                            setState(() {
                              if(username.text !="" &&
                                  userstatus.text ==""){
                                userstatus.text = status.toString();
                                path1 = profileimg;
                              }
                              else if(username.text =="" &&
                                  userstatus.text !=""){
                                username.text = name.toString();
                                path1 = profileimg;
                              }
                              else{
                                username.text = name.toString();
                                userstatus.text = status.toString();
                                path1 = profileimg;
                              }
                              isLoading = true;
                            });
                            if (isLoading) {
                              loadDialog();
                            }
                            search(username.text);
                            searchSkill(userstatus.text);
                            print(FirebaseAuth.instance.currentUser.uid);
                            Future.delayed(const Duration(seconds: 5),
                                    () async {
                                  await updateUsers(username.text, email.toString(),
                                      widget.phone, path1, userstatus.text,searchString,searchskill);
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
                                  title: Text('Error'),
                                  content: Text(
                                      'Please Connect To Our Team'),
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