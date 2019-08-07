import 'dart:convert';

import 'package:JustMusic/global_components/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin{
  Map<String, dynamic> user;
  final _storage = FlutterSecureStorage();
  Future<void> userFuture;
  List<dynamic> _myPosts = [];
  List<dynamic> _myLikes = [];
  List<dynamic> _myBlocks = [];
  Future<List<dynamic>> _fetchMyPosts;
  TabController _tabController;
  Future<List<dynamic>> _fetchLikedMusic;
  Future<List<dynamic>> _fetchBlockedMusic;
  int _currentTabIndex = 0;

  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0)
    ..addListener((){
      print(_tabController.index);
      switch (_tabController.index) {
        case 0:
          if (_myPosts.isEmpty) {
            _fetchMyPosts.then((posts) {
              setState(() {
                _myPosts..addAll(posts);
              });
            });
          }
          break;
        case 1:
          if (_myLikes.isEmpty) {
            _fetchLikedMusic
                .then((posts) {
              setState(() {
                _myLikes..addAll(posts);
              });
            });
          }
          break;
        case 2:
          if (_myBlocks.isEmpty) {
            _fetchBlockedMusic
                .then((posts) {
              setState(() {
                _myBlocks..addAll(posts);
              });
            });
          }
      }
      setState((){
        _currentTabIndex = _tabController.index;
      });
    });
    userFuture = getUserFromStorage().then((user) {
      if (user != null) {
        _fetchMyPosts = MusicApi.getMyPosts(user["_id"]);
        _fetchLikedMusic = MusicApi.getVideosFor("likes", user["_id"]);
        _fetchBlockedMusic = MusicApi.getVideosFor("blocks", user["_id"]);

        _fetchMyPosts.then((posts) {
          setState(() {
            this.user = user;
            _myPosts..addAll(posts);
          });
        });
      }
    });
  }

  Future<dynamic> getUserFromStorage() async {
    var user = await _storage.read(key: "user").then((userJson) {
      return jsonDecode(userJson)["user"];
    });
    print("user: $user");
    return user;
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.white54, Colors.white],
  ).createShader(Rect.fromLTWH(80.0, 0.0, 200, 70.0));

  Widget _tabView(type) {
    var sources = {
      "myPosts": _myPosts,
      "myLikes": _myLikes,
      "myBlocks": _myBlocks
    };
    return Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: ListView(
            padding: EdgeInsets.only(bottom: 50),
            children: []..addAll(sources[type].map((post) {
                return Container(
                    height: 85,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(children: [
                      ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: 100, maxHeight: 70),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white54, width: 0.5)),
                              width: 107,
                              height: 60,
                              child: post['thumbnailUrl'] != null
                                  ? Image.network(post['thumbnailUrl'])
                                  : Image.network(
                                      "https://ik.imagekit.io/kitkitkitit/tr:q-100,w-106,h-62/thumbnail-default.jpg"))),
                      Flexible(
                          child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text("${post["title"]}",
                                  style: TextStyle(color: Colors.white))))
                    ]));
              }))));
  }

  @override
  Widget build(BuildContext context) {
    print(_currentTabIndex);
    return FutureBuilder(
        future: userFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                    backgroundColor: Color.fromRGBO(20, 20, 25, 1),
                    body: Column(children: [
                      Stack(children: [
                        Column(children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * .2,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/default_appbar_image.jpg"),
                                      fit: BoxFit.cover))),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.30,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    stops: [
                                      0,
                                      1
                                    ],
                                    colors: [
                                      Color.fromRGBO(20, 20, 30, .6),
                                      Color.fromRGBO(60, 60, 70, .7),
                                    ]),
                              ),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(top: 50),
                                        child: Text(
                                            user != null
                                                ? user['nickname']
                                                : "",
                                            style: TextStyle(
                                                fontFamily: "NotoSans",
                                                fontSize: 18,
                                                color: Colors.white))),
                                    Container(
                                        child: Text(
                                            user != null
                                                ? "${user['followers']} Followers"
                                                : "?",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: "NotoSans",
                                                color: Colors.white))),
                                    Container(
                                        child: Text("0 Likes on my posts",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: "NotoSans",
                                                color: Colors.white))),
                                    Container(
                                        margin: EdgeInsets.only(top: 5),
                                        height: 50,
                                        child: TabBar(
                                          controller: _tabController,
                                          indicatorColor:
                                              Color.fromRGBO(247, 221, 68, 1),
                                          unselectedLabelColor: Colors.white54,
                                          tabs: [
                                            Tab(
                                                child:
                                                Row(children: [
                                                  Text("My Posts "),
                                                  _currentTabIndex == 0 ? Text("${_myPosts.length}", style: TextStyle(color: Color.fromRGBO(247, 221, 68, 1))
                                                  ): Container()])),
                                            Tab(
                                                child:
                                                Row(children: [
                                                  Text("My Likes "),
                                                  _currentTabIndex == 1 ? Text("${_myLikes.length}", style: TextStyle(color: Color.fromRGBO(247, 221, 68, 1))
                                                  ): Container()])
                                            ),
                                            Tab(
                                                child:
                                                Row(children: [
                                                  Text("Blocked "),
                                                  _currentTabIndex == 2 ? Text("${_myBlocks.length}", style: TextStyle(color: Color.fromRGBO(247, 221, 68, 1))
                                                  ): Container()])),
                                          ],
                                        )),
                                  ])),
                        ]),
                        Positioned(
                            top: MediaQuery.of(context).size.height * .2 - 35,
                            left: MediaQuery.of(context).size.width * .5 - 52.5,
                            child: Container(
                                width: 105,
                                height: 105,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromRGBO(70, 70, 80, 1)),
                                child: IconButton(
                                    icon: Icon(Icons.photo_camera,
                                        color: Colors.white70),
                                    iconSize: 35,
                                    onPressed: null))),
                      ]),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              FutureBuilder(
                                future: _fetchMyPosts,
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done){
                                      return _tabView("myPosts");
                                    }else if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }else {
                                      return Center(child: Text("Error fetching data"));
                                    }
                                  }),
                              FutureBuilder(
                                  future: _fetchLikedMusic,
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done){
                                      return _tabView("myLikes");
                                    }else if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }else {
                                      return Center(child: Text("Error fetching data"));
                                    }
                                  }),
                              FutureBuilder(
                                  future: _fetchBlockedMusic,
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done){
                                      return _tabView("myBlocks");
                                    }else if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }else {
                                      return Center(child: Text("Error fetching data"));
                                    }
                                  })
                            ],
                          ))
                    ]));
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
