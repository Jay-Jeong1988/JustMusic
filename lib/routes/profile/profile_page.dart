import 'dart:convert';

import 'package:JustMusic/global_components/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> user;
  final _storage = FlutterSecureStorage();
  Future<void> userFuture;
  List<dynamic> _myPosts = [];
  Future<List<dynamic>> _fetchMyPosts;

  void initState() {
    super.initState();
    userFuture = getUserFromStorage().then((user){
        _fetchMyPosts = user != null ? MusicApi.getMyPosts(user["_id"]) : null;
        _fetchMyPosts.then((posts){
          setState((){
            _myPosts..addAll(posts);
          });
      });
    });
  }

  Future<dynamic> getUserFromStorage() async {
    var user = await _storage.read(key: "user").then((userJson){
      return jsonDecode(userJson)["user"];
    });
    print("user: $user");
    return user;
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.white54, Colors.white],
  ).createShader(Rect.fromLTWH(80.0, 0.0, 200, 70.0));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: userFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return DefaultTabController(
                length: 2,
                child: Scaffold(
                    backgroundColor: Color.fromRGBO(20, 20, 25, 1),
                    body: Column(children: [Stack(children: [
                      Column(children: [
                        Container(width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * .2,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/default_appbar_image.jpg"),
                          fit: BoxFit.cover)
                        ))
                        ,
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.30,
                        decoration: BoxDecoration(gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          stops:[0, 1],
                          colors: [Color.fromRGBO(20, 20, 30, .6),
                            Color.fromRGBO(60, 60, 70, .7),]
                        ),),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                      Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Text(user != null ? user['nickname'] : "",
                              style: TextStyle(fontFamily: "NotoSans",
                              fontSize: 18,
                              color: Colors.white))),
                      Container(
                          child: Text("0 Likes on my posts",
                              style: TextStyle(fontSize: 13,
                              fontFamily: "NotoSans",
                              color: Colors.white))),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              height: 50,
                                child: TabBar(
                                  indicatorColor: Color.fromRGBO(247, 221, 68, 1),
                                  unselectedLabelColor: Colors.white54,
                                  tabs: [Tab(text: "My Posts"), Tab(text: "My Likes")],
                                )),
                          ])),
                      ]),Positioned(top: 90, left: MediaQuery.of(context).size.width * .5 - 45
                          ,child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromRGBO(70, 70, 80, 1)),
                          child: IconButton(
                              icon: Icon(Icons.photo_camera, color: Colors.white70),
                              iconSize: 35,
                              onPressed: null))),
                    ]),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.3,
                          child:
                          TabBarView(
                            children: [
                          ListView(children: []..addAll(_myPosts.map((post){
                            return Text("${post["title"]}", style:TextStyle(color: Colors.white));
                          }))
                          ),
                ListView(children: [Icon(Icons.directions_transit)]),
                            ],
                          ))
                    ])));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Column(children: <Widget>[
              Text('Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 14.0, color: Colors.white)),
              RaisedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Exit"),
                  textColor: Colors.white,
                  elevation: 7.0,
                  color: Colors.blue)
            ]));
          } else {
            return Center();
          }
        });
  }
}
