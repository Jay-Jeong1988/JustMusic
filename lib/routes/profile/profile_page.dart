import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../global_components/geolocation.dart';
import '../../models/user.dart';

class ProfilePage extends StatefulWidget {
//  ProfilePage(Key key, user) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> user;
  final _storage = FlutterSecureStorage();
  Future<void> userFuture;

  void initState(){
    userFuture = getUserFromStorage();
  }

  Future<void> getUserFromStorage() async{
    await _storage.read(key: "user").then((userJson){
      user = jsonDecode(userJson)["user"];
      print("user: $user");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: userFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.connectionState == ConnectionState.done) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center
                ,children: [
                  Text(
                      "Profile page coming soon:\n ${user != null ? user["nickname"] : 's'}", style: TextStyle(color: Colors.white)
                  )
                ]));
          }else if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else if(snapshot.hasError){
            return Center(
                child: Column(children: <Widget>[
                  Text('Error: ${snapshot.error}',
                      style:
                      TextStyle(fontSize: 14.0, color: Colors.white)),
                  RaisedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Exit"),
                      textColor: Colors.white,
                      elevation: 7.0,
                      color: Colors.blue)
                ]));
          }else {
            return Center();
          }
        });
    }
}
