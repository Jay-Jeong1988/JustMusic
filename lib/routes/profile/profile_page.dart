import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/models/user.dart';
import 'package:JustMusic/routes/home/home_page.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  User _user;
  List<dynamic> _myPosts = [];
  List<dynamic> _myLikes = [];
  List<dynamic> _myBlocks = [];
  Future<dynamic> _fetchMyPosts;
  TabController _tabController;
  Future<dynamic> _fetchLikedMusic;
  Future<dynamic> _fetchBlockedMusic;
  int _currentTabIndex = 0;
  int totalLikes = 0;
  Singleton _singleton = Singleton();
  int _myPostsLastIndex = 0;
  int _myLikesLastIndex = 0;
  int _myBlocksLastIndex = 0;
  int _myPostsTotalCountInDB = 0;
  int _myLikesTotalCountInDB = 0;
  int _myBlocksTotalCountInDB = 0;
  ScrollController _listViewScrollController;

  void initState() {
    super.initState();
    _listViewScrollController = new ScrollController()..addListener(_scrollListener);

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0)
      ..addListener(() {
        switch (_tabController.index) {
          case 0:
            if (_myPosts.isEmpty) {
              _fetchMyPosts.then((res) {
                setState(() {
                  _myPosts..addAll(res["posts"]);
                  _myPostsLastIndex+=10;
                  if (res["count"] != null) _myPostsTotalCountInDB=res['count'];
                });
              });
            }
            break;
          case 1:
            if (_myLikes.isEmpty) {
              _fetchLikedMusic.then((res) {
                setState(() {
                  _myLikes..addAll(res['posts']);
                  _myLikesLastIndex += 10;
                  if (res["count"] != null) _myLikesTotalCountInDB=res['count'];
                });
              });
            }
            break;
          case 2:
            if (_myBlocks.isEmpty) {
              MusicApi.getVideosFor('blocks', _user.id, _myBlocksLastIndex).then((res) {
                setState(() {
                  _myBlocks..addAll(res['posts']);
                  _myBlocksLastIndex += 10;
                  if (res["count"] != null) _myBlocksTotalCountInDB=res['count'];
                });
              });
            }
        }
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      });
    _user = _singleton.user;
    if (_user != null) {
      _fetchMyPosts = MusicApi.getMyPosts(_user.id, _myPostsLastIndex);
      _fetchLikedMusic = MusicApi.getVideosFor("likes", _user.id, _myLikesLastIndex);
      _fetchBlockedMusic = MusicApi.getVideosFor("blocks", _user.id, _myBlocksLastIndex);

      _fetchMyPosts.then((res) {
        for (var post in res["posts"]) {
          totalLikes += post['likesCount'];
        }
        setState(() {
          _myPosts..addAll(res["posts"]);
          _myPostsLastIndex += 10;
          if (res["count"] != null) _myPostsTotalCountInDB = res["count"];
        });
      });
    }
  }

  void _showDialog(musicId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text("Are you sure you want to unblock the video?",
              style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Yes", style: TextStyle(fontSize: 20)),
              onPressed: () {
                MusicApi.perform("unblock", _user.id, musicId).then((result) {
                  MusicApi.getVideosFor("blocks", _user.id, 0).then((result) {
                    setState(() {
                      _myBlocks = result["posts"];
                      _myBlocksLastIndex=10;
                      _myBlocksTotalCountInDB-=1;
                    });
                  });
                  Navigator.of(context).pop();
                });
              },
            ),
            new FlatButton(
              child: new Text("No", style: TextStyle(fontSize: 20)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _scrollListener() {
    if (_listViewScrollController.position.extentAfter <= 0) {
      if (_currentTabIndex == 0 && _myPosts.length < _myPostsTotalCountInDB) {
        MusicApi.getMyPosts(_user.id, _myPostsLastIndex).then((res) {
          setState(() {
            _myPosts.addAll(res["posts"]);
            _myPostsLastIndex += 10;
          });
        });
      }else if (_currentTabIndex == 1 && _myLikes.length < _myLikesTotalCountInDB) {
        MusicApi.getVideosFor('likes', _user.id, _myLikesLastIndex).then((res) {
          setState(() {
            _myLikes.addAll(res["posts"]);
            _myLikesLastIndex += 10;
          });
        });
      }else if (_currentTabIndex == 2 && _myBlocks.length < _myBlocksTotalCountInDB) {
        MusicApi.getVideosFor('blocks', _user.id, _myBlocksLastIndex).then((res) {
          setState(() {
            _myBlocks.addAll(res["posts"]);
            _myBlocksLastIndex += 10;
          });
        });
      }
    }
  }

  Widget _tabView(type) {
    var sources = {
      "myPosts": _myPosts,
      "myLikes": _myLikes,
      "myBlocks": _myBlocks
    };
    var items = sources[type];
    return Container(
      width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.42,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(children: [
          Container(
              decoration: BoxDecoration(color: Colors.transparent),
              child: ListView.builder(
                controller: _listViewScrollController,
                itemCount: sources[type].length,
                  padding: EdgeInsets.only(top: 20, bottom: 50),
                  itemBuilder: (context, index){
                    return Container(
                        height: 90,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: 113, maxHeight: 70),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white54, width: 0.5)),
                                width: 113,
                                height: 67,
                                child: Stack(children: [
                                  items[index]['thumbnailUrl'] != null
                                      ? Center(
                                      child: Image.network(
                                          items[index]['thumbnailUrl']))
                                      : Center(
                                      child: Image.network(
                                          "https://ik.imagekit.io/kitkitkitit/tr:q-100,w-106,h-62/thumbnail-default.jpg")),
                                  type == "myPosts"
                                      ? Positioned(
                                      top: 0,
                                      left: 2,
                                      child: Container(
                                          child: Stack(children: [
                                            Center(
                                                child: Text(
                                                    "${items[index]['likesCount']}",
                                                    style: TextStyle(
                                                        fontFamily:
                                                        "BalooChettan",
                                                        fontWeight:
                                                        FontWeight.normal,
                                                        color: Color.fromRGBO(
                                                            220,
                                                            100,
                                                            128,
                                                            1))))
                                          ])))
                                      : type == "myBlocks"
                                      ? Center(
                                      child: IconButton(
                                          icon: Icon(Icons.block),
                                          color: Color.fromRGBO(
                                              255, 0, 0, 1),
                                          iconSize: 50,
                                          onPressed: () =>
                                              _showDialog(
                                                  items[index]["_id"])))
                                      : Container()
                                ]),
                              )),
                          Flexible(
                              child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                  child: Stack(children: [
                                    InkWell(
                                        onTap: () {
                                          if (type == "myBlocks")
                                            _showDialog(items[index]["_id"]);
                                        },
                                        child: Text("${items[index]["title"]}",
                                            style: TextStyle(
                                                color: Colors.white))),
                                  ])))
                        ]));
                  })),
        ]));
  }

  void _playBtnPressed () {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext
            context) =>
                AppScreen(
                    navigatedPage: HomePage(
                       ))));
    _singleton.clicked = 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchMyPosts,
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
                                        _user != null ? _user.nickname : "",
                                        style: TextStyle(
                                            fontFamily: "NotoSans",
                                            fontSize: 18,
                                            color: Colors.white))),
                                Container(
                                    child: Text(
                                        _user != null
                                            ? "${_user.followers} Followers"
                                            : "?",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: "NotoSans",
                                            color: Colors.white))),
                                Container(
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                      Text("$totalLikes Likes ",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: "BalooChettan",
                                              color: Color.fromRGBO(
                                                  220, 100, 128, 1))),
                                      Text("on my posts",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontFamily: "NotoSans",
                                              color: Colors.white))
                                    ])),
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
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                              Text("My Posts "),
                                              _currentTabIndex == 0
                                                  ? Text("$_myPostsTotalCountInDB",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              247, 221, 68, 1)))
                                                  : Container()
                                            ])),
                                        Tab(
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                              Text("My Likes "),
                                              _currentTabIndex == 1
                                                  ? Text("$_myLikesTotalCountInDB",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              247, 221, 68, 1)))
                                                  : Container()
                                            ])),
                                        Tab(
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                              Text("Blocked "),
                                              _currentTabIndex == 2
                                                  ? Text("$_myBlocksTotalCountInDB",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              247, 221, 68, 1)))
                                                  : Container()
                                            ])),
                                      ],
                                    )),
                              ])),
                    ]),
                    Positioned(
                        top: MediaQuery.of(context).size.height * .2 - MediaQuery.of(context).size.height * .15 * .33,
                        left: MediaQuery.of(context).size.width * .5 - MediaQuery.of(context).size.height * .15 * .5,
                        child: Container(
                            width: MediaQuery.of(context).size.height * .15 ,
                            height: MediaQuery.of(context).size.height * .15,
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
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return _tabView("myPosts");
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return Center(
                                      child: Text("Error fetching data"));
                                }
                              }),
                          FutureBuilder(
                              future: _fetchLikedMusic,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return _tabView("myLikes");
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return Center(
                                      child: Text("Error fetching data"));
                                }
                              }),
                          FutureBuilder(
                              future: _fetchBlockedMusic,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return _tabView("myBlocks");
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return Center(
                                      child: Text("Error fetching data"));
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
