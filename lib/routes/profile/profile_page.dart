import 'package:flutter/material.dart';

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
    return Scaffold(
        body: Stack(children: [
        Center(
        child: Text(
        "Profile Page ${widget.user != null ? widget.user.nickname : 's'}", style: TextStyle(color: Colors.white)
        ))
    ])
    );}
}
