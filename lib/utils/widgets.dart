import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/auth/authentication.dart';
import 'package:chatapp/screens/photo.dart';
import 'package:chatapp/screens/profile.dart';
import 'package:chatapp/screens/video.dart';
import 'package:chatapp/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const social_textColorPrimary = Color(0xFF333333);

Widget text(String text,
    {var fontSize = 16.0,
    textColor = social_textColorPrimary,
    var fontFamily = 'Regular',
    var isCentered = false,
    var maxLine = 1,
    var latterSpacing = 0.25,
    var textAllCaps = false,
    var isLongText = false}) {
  return Text(
    textAllCaps ? text.toUpperCase() : text,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        color: textColor,
        height: 1.5,
        letterSpacing: latterSpacing),
  );
}

BoxDecoration boxDecoration(
    {double radius = 10.0,
      Color color = Colors.transparent,
      Color bgColor = Colors.white,
      var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow ? [BoxShadow(
        color: Color(0X95E9EBF0), blurRadius: 10,
        spreadRadius: 2)] : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

Widget imageMessage(context,imageUrlFromFB) {
  return Container(
    width: 160,
    height: 160,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(
              builder: (context) => FullPhoto(url: imageUrlFromFB)
          )
        );
      },
      child: CachedNetworkImage(
        imageUrl: imageUrlFromFB,
        placeholder: (context, url) => Container(
          transform: Matrix4.translationValues(0, 0, 0),
          child: Container( width: 60, height: 80,
              child: Center(child: new CircularProgressIndicator())),
        ),
        errorWidget: (context, url, error) => new Icon(Icons.error),
        width: 60,
        height: 80,
        fit: BoxFit.cover,
      ),
    ),
  );
}

Widget videoMessage(context,videoUrlFromFB) {
  return Container(
    width: 160,
    height: 160,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(url: videoUrlFromFB)
        )
        );
      },
      child: VideoPlayerScreen(url: videoUrlFromFB),
    ),
  );
}


//ignore: must_be_immutable
class SocialAppButton extends StatefulWidget {
  var textContent;
  VoidCallback onPressed;

  SocialAppButton({@required this.textContent, @required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return SocialAppButtonState();
  }
}

class SocialAppButtonState extends State<SocialAppButton> {
  final ButtonStyle elevatedButtonStyle = TextButton.styleFrom(
    textStyle: TextStyle(
      color: Color(0xFFffffff),
    ),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    padding: EdgeInsets.all(0),
  );
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: Colors.blue),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: widget.textContent,
                      style: TextStyle(fontSize: 16.0)),
                  WidgetSpan(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.arrow_forward,
                            color: Color(0xFFffffff), size: 16)),
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

// ignore: non_constant_identifier_names
Widget SocialOption(BuildContext context, var color, var icon, var value, var subValue, {var tags}) {
  var width = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: () {
    },
    child: Row(
      children: <Widget>[
        Container(
          decoration: boxDecoration(showShadow: false, radius: 10.0, bgColor: color),
          width: width * 0.13,
          height: width * 0.13,
          padding: EdgeInsets.all(10.0),
          child: SvgPicture.asset(icon, color: Color(0xFFffffff)),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[text(value, fontFamily: 'Medium'),
              text(subValue, textColor: Colors.black45,
                  isLongText: false)
            ],
          ),
        )
      ],
    ),
  );
}

Widget mToolbar(BuildContext context, var title, var icon, {var tags}) {
  var width = MediaQuery.of(context).size.width;
  return Container(
    width: MediaQuery.of(context).size.width,
    height: width * 0.15,
    color: Color(0xFFffffff),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        title=="INMOOD"? Container():GestureDetector(
          onTap: () {
            back(context);
          },
          child: Container(
            margin: EdgeInsets.only(left: 16.0),
            width: width * 0.1,
            height: width * 0.1,
            decoration: boxDecoration(showShadow: false, bgColor: Colors.blue),
            child: Icon(Icons.keyboard_arrow_left, color: Color(0xFFffffff)),
          ),
        ),
        Center(
          child: title=="INMOOD"? Row(
            children: [
              SizedBox(width:22),
              Image.asset("images/walk.png",height: 40 ,width: 150,),
            ],
          ):text(title, fontFamily: 'Bold', fontSize: 18.0, textAllCaps: true),
        ),
        GestureDetector(
          onTap: () {
            if(tags=="Profile"){
              Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SocialProfile()));
            } else if(tags=="logout"){
              AuthServices _auth = new AuthServices();
              _auth.signOut(context);
            }
          },
          child: tags =="Profile" ? Container(
              margin: EdgeInsets.only(right: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                child: CachedNetworkImage(
                    imageUrl: icon,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover),
              )
          )
          /*Container(
              margin: EdgeInsets.only(right: 16.0),
              decoration: boxDecoration(radius: 10.0),
              child: CachedNetworkImage(
                imageUrl: icon,
                fit: BoxFit.contain,
              ),)*/
              :Container(
                margin: EdgeInsets.only(right: 16.0),
                width: width * 0.1,
                height: width * 0.1,
                padding: EdgeInsets.all(6),
                decoration: boxDecoration(showShadow: false, bgColor: Color(0xFFDADADA)),
                child: Icon(icon, color: Color(0xFF333333),)),
        ),
      ],
    ),
  );
}

Widget mTop(BuildContext context, var title, {var tags}) {
  var width = MediaQuery.of(context).size.width;
  return Container(
    width: MediaQuery.of(context).size.width,
    height: width * 0.15,
    color: Color(0xFFffffff),
    child: Stack(
      children: <Widget>[
        GestureDetector(
            onTap: () {
              back(context);
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 16.0),
                width: width * 0.1,
                height: width * 0.1,
                decoration: boxDecoration(showShadow: false, bgColor: Colors.blue),
                child: Icon(Icons.keyboard_arrow_left, color: Color(0xFFffffff)),
              ),
            )),
        Center(
          child: text(title, fontFamily: 'Bold', fontSize: 18.0, textAllCaps: true),
        ),
      ],
    ),
  );
}

//ignore: must_be_immutable
class SocialBtn extends StatefulWidget {
  var textContent;
  VoidCallback onPressed;

  SocialBtn({@required this.textContent, @required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return SocialBtnState();
  }
}

class SocialBtnState extends State<SocialBtn> {
  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    textStyle: TextStyle(
      color: Color(0xFFffffff),
    ),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    padding: EdgeInsets.all(0),
  );
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Color(0xFF494FFB)
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: text(widget.textContent, textColor: Color(0xFFffffff)),
          ),
        ),
      ),
    );
  }
}

TextStyle primaryTextStyle1(
    {int size = 16, Color textColor = const Color(0xFF000000)}) {
  return TextStyle(
    fontSize: size.toDouble(),
    color: textColor,
  );
}

TextStyle secondaryTextStyle(
    {int size = 14, Color textColor = const Color(0xFF757575)}) {
  return TextStyle(
    fontSize: size.toDouble(),
    color: textColor,
  );
}


BoxDecoration boxDecorations(
    {double radius = 8,
      Color color = Colors.transparent,
      Color bgColor = Colors.white,
      var showShadow = false}) {
  return BoxDecoration(
      color: bgColor,
      //gradient: LinearGradient(colors: [bgColor, whiteColor]),
      boxShadow: showShadow
          ? [BoxShadow(color:  Color(0x95E9EBF0), blurRadius: 10, spreadRadius: 2)]
          : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color),
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

//ignore: must_be_immutable
class CustomImage extends StatelessWidget {
  String img;
  CustomImage({this.img});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        child: Align(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: img, fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(8)),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}