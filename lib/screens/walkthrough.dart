import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/signin.dart';
import 'package:chatapp/utils/widgets.dart';
import 'package:flutter/material.dart';

class SocialWalkThrough extends StatefulWidget {
  static String tag = '/SocialWalkThrough';

  @override
  SocialWalkThroughState createState() => SocialWalkThroughState();
}

class SocialWalkThroughState extends State<SocialWalkThrough> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF8F7F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      text("Welcome to ",
                          fontFamily: 'Bold', fontSize: 24.0),
                      Image.asset("images/walk.png",height: 50,width: 150,)    
                    ],
                  ),
                  SizedBox(height: 40.0),
                  CachedNetworkImage(
                      imageUrl:
                          "https://image.freepik.com/free-vector/conversation-concept-illustration-flat-style-communication-chat-conversation_198838-120.jpg",
                      height: width * 0.55),
                  SizedBox(height: 40.0),
                  Container(
                    margin: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0),
                    child: text(
                        "Read our Privacy Policy. Tap Agree and Continue to accept the Terms of Services.",
                        isLongText: true,
                        textColor: Color(0xFF9D9D9D),
                        isCentered: true),
                  ),
                  SizedBox(height: 40.0),
                  Container(
                    margin: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0),
                    child: SocialAppButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SocialSignIn()));
                      },
                      textContent: "Agree & Continue",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
