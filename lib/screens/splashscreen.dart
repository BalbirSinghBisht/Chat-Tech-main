import 'package:chatapp/screens/walkthrough.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'dashboard.dart';

class Splash extends StatefulWidget{
  @override
  _Splash createState() => _Splash();
}

class _Splash extends State<Splash>{

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      backgroundColor: Colors.white,
      seconds: 2,
      navigateAfterSeconds: FirebaseAuth.instance.currentUser!=null ? SocialDashboard() : SocialWalkThrough(),
      image: new Image.asset('images/chatlogo.png'),
      loadingText: Text("Loading...."),
      photoSize: 200.0,
      loaderColor: Colors.blue,
    );
  }
}