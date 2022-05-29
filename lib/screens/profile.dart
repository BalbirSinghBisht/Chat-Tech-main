import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/screens/updatedetails.dart';
import 'package:chatapp/screens/updateprofilepic.dart';
import 'package:chatapp/services/dbdata.dart';
import 'package:chatapp/utils/extensions.dart';
import 'package:chatapp/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';

class SocialProfile extends StatefulWidget {
  static String tag = '/SocialProfile';

  @override
  SocialProfileState createState() => SocialProfileState();
}

class SocialProfileState extends State<SocialProfile> {

  Widget mOption(var value, var icon, {var tag}) {
    return GestureDetector(
      onTap: () {
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding:
            EdgeInsets.fromLTRB(8.0, 16, 8.0, 16),
        decoration: boxDecoration(showShadow: false, color: Color(0xFFDADADA)),
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    icon,
                    color: Color(0xFF333333),
                    size: 18,
                  ),
                ),
              ),
              TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16.0,
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mProfile() {
    var width = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
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
              height: width * 0.25,
              width: width * 0.25,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(Colors.transparent);
    return Scaffold(
      backgroundColor: Color(0xFFF8F7F7),
      floatingActionButton: SpeedDialFabWidget(
        primaryIconExpand: Icons.add,
        primaryIconCollapse: Icons.close,
        secondaryIconsList: [
          Icons.edit,
          Icons.add_a_photo
        ],
        secondaryIconsText: [
          "Edit Details",
          "Edit Pic",
        ],
        secondaryIconsOnPress: [
          () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateDetails()))
          },
          () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfilePic()))
          },
        ],
        secondaryBackgroundColor: Colors.cyan,
        secondaryForegroundColor: Colors.white,
        primaryBackgroundColor: Colors.cyan,
        primaryForegroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            mToolbar(context, "Accounts", Icons.exit_to_app_outlined,
                tags: "logout"),
            Expanded(
              child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        mProfile(),
                        SizedBox(
                          height: 16.0,
                        ),
                        mOption(name, Icons.account_circle_outlined,),
                        SizedBox(
                          height: 16.0,
                        ),
                        mOption(status, Icons.help_outline),
                        SizedBox(
                          height: 16.0,
                        ),
                        mOption(phone, Icons.call),
                        SizedBox(
                          height: 16.0,
                        ),
                        mOption(email, Icons.email),
                      ],
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
