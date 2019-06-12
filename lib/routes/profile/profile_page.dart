import 'package:flutter/material.dart';
import '../../global_components/geolocation.dart';

class ProfilePage extends StatefulWidget {
//  ProfilePage(Key key, user) : super(key: key);
  var user;
  ProfilePage(user){ this.user = user; }

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center
        ,children: [
        Text(
        "Profile Page ${widget.user != null ? widget.user.nickname : 's'}", style: TextStyle(color: Colors.white)
        ),
          GeoListenPage()
    ]));
    }
}
