import 'package:chatapp/screens/splashscreen.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:chatapp/utils/extensions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
  }catch (e) {
    print(e);
  }
  await Firebase.initializeApp();
  await getUser();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    changeStatusColor(Colors.transparent);
    return MaterialApp(
      title: 'Chat-Tech',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}