import 'package:chatapp/screens/dashboard.dart';
import 'package:chatapp/screens/userdetails.dart';
import 'package:chatapp/screens/walkthrough.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  String error = "", phoneNo = "", userOtp = "", otpError = "";
  //SignIn With Phone
  Future<bool> signInPhone(
      TextEditingController phone, BuildContext context) async {
    phoneNo = "+91 ${phone.text}";
    print(phoneNo);
    FirebaseAuth _auth = FirebaseAuth.instance;
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      padding: EdgeInsets.all(0),
      textStyle: TextStyle(
        color: Color(0xFFFFFFFF)
      ),
    );
    //Phone Authentication Verify
    _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          loading = true;

          UserCredential result = await _auth.signInWithCredential(credential);
          User user = result.user;

          if (user != null) {
            Navigator.of(context).pop();
            await getUser().then((value) => existence == true
                ? Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SocialDashboard()),
                    (route) => false)
                : Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserDetails(
                              phone: phone.text,
                            )),
                    (route) => false));
          } else {
            loading = false;
            error = "Validation Error, Please try again in sometime";
          }
        },
        verificationFailed: (FirebaseAuthException exception) {
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 10.0),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // To make the card compact
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            padding: EdgeInsets.all(16),
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.close, color: Colors.black)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text('An OTP has been sent to',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Bold",
                              fontSize: 18.0,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: Text('+91 ' + phone.text,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Bold",
                              fontSize: 18.0,
                            )),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 10, 4, 8),
                            hintText: "OTP",
                            labelText: "Enter OTP",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFB4BBC2), width: 0.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFB4BBC2), width: 0.0),
                            ),
                          ),
                          onChanged: (value) {
                            userOtp = value;
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(otpError,
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: "Regular",
                            fontSize: 14.0,
                          )),
                      SizedBox(height: 26),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: <Color>[
                              Color(0xFF3a5af9),
                              Color(0xFF7449fa)
                            ]),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16)),
                            shape: BoxShape.rectangle,
                          ),
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () async {
                              otpError = "";
                              print(userOtp);
                              AuthCredential credential =
                                  PhoneAuthProvider.credential(
                                      verificationId: verificationId,
                                      smsCode: userOtp);

                              UserCredential result =
                                  await _auth.signInWithCredential(credential);
                              //await fetchData();

                              User user = result.user;

                              if (user != null) {
                                loading = true;
                                Navigator.of(context).pop();

                                Future.delayed(const Duration(seconds: 2),
                                    () async {
                                  await getUser().then((value) => existence ==
                                          true
                                      ? Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SocialDashboard()),
                                          (route) => false)
                                      : Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => UserDetails(
                                                    phone: phone.text,
                                                  )),
                                          (route) => false));
                                });
                              } else {
                                otpError = "Please enter a valid OTP";
                              }
                            },
                            style: flatButtonStyle,
                            child: Text(
                              "Sign In",
                              style:
                                  TextStyle(fontSize: 16, fontFamily: "Bold"),
                              textAlign: TextAlign.center,
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }
  //SignOut
  Future signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SocialWalkThrough()),
        (route) => false);
  }
}