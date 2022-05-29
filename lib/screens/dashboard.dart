import 'dart:io';

import 'package:chatapp/screens/homechats.dart';
import 'package:chatapp/screens/homestatus.dart';
import 'package:chatapp/screens/searchusers.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:chatapp/utils/extensions.dart';
import 'package:chatapp/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class SocialDashboard extends StatefulWidget {
  static String tag = '/SocialDashboard';

  @override
  SocialDashboardState createState() => SocialDashboardState();
}

class SocialDashboardState extends State<SocialDashboard> {
  int selectedPos = 0;
  status() async{
    SocialHomeStatusState().getProfileImage();
  }

  @override
  void initState() {
    super.initState();
    selectedPos = 0;
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Colors.transparent);

    Future<bool> _onBackPressed() {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  exit(0);
                },
              )
            ],
          );
        },
      ) ?? false;
    }

    return WillPopScope(
        child: Scaffold(
          floatingActionButton: selectedPos == 1
              ? Container(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: () {
                        status();
                      },
                      backgroundColor: Colors.cyan,
                      child: Icon(Icons.image),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ],
                ),
          )
              : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Search()));
                },
                backgroundColor: Colors.cyan,
                child: Icon(Icons.chat),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
          backgroundColor: Color(0xFFF8F7F7),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                mToolbar(context, "INMOOD", profileimg,
                    tags: "Profile"),
                SizedBox(height: 16.0-13),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16.0),
                  child: CupertinoSlidingSegmentedControl(
                      thumbColor: Colors.cyan[100],
                      children: {
                        0: Container(
                            padding: EdgeInsets.all(8),
                            child: Text('Chats',
                              style: primaryTextStyle(
                                  color: selectedPos== 0 ? blackColor: grey),
                            )),
                        1: Container(
                            padding: EdgeInsets.all(8),
                            child: Text('Status',style: primaryTextStyle(
                                color: selectedPos== 1 ? blackColor: grey),
                            )),
                      },
                      groupValue: selectedPos,
                      onValueChanged: (newValue) {
                        setState(() {
                          selectedPos = newValue;
                        });
                      }),
                ),
                if (selectedPos == 0) SocialHomeChats(),
                if (selectedPos == 1) SocialHomeStatus(),
              ],
            ),
          )
        ),
        onWillPop: _onBackPressed,
    );
  }
}
