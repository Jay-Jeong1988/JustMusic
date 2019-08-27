import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  var _controller = YoutubePlayerController();
  bool _musicActivated = false;
  List<dynamic> _currentlySelectedPlayList = [];
  int _currentlyPlayingIndex = 0;
  bool _isPaused = false;
  bool _isRepeatOn = false;
  bool _isRepeatAllOn = false;
  List<dynamic> _myPlayLists = [];

  void initState() {
    super.initState();
    PlayListApi.getMyPlayLists(_singleton.user.id).then((playLists) {
      setState(() {
        _myPlayLists.addAll(playLists);
      });
    });

    _listViewScrollController = new ScrollController()
      ..addListener(_scrollListener);

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0)
      ..addListener(() {
        switch (_tabController.index) {
          case 0:
            if (_myPosts.isEmpty) {
              _fetchMyPosts.then((res) {
                setState(() {
                  _myPosts..addAll(res["posts"]);
                  _myPostsLastIndex += 10;
                  if (res["count"] != null)
                    _myPostsTotalCountInDB = res['count'];
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
                  if (res["count"] != null)
                    _myLikesTotalCountInDB = res['count'];
                });
              });
            }
            break;
          case 2:
            if (_myBlocks.isEmpty) {
              MusicApi.getVideosFor('blocks', _user.id, _myBlocksLastIndex)
                  .then((res) {
                setState(() {
                  _myBlocks..addAll(res['posts']);
                  _myBlocksLastIndex += 10;
                  if (res["count"] != null)
                    _myBlocksTotalCountInDB = res['count'];
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
      _fetchLikedMusic =
          MusicApi.getVideosFor("likes", _user.id, _myLikesLastIndex);
      _fetchBlockedMusic =
          MusicApi.getVideosFor("blocks", _user.id, _myBlocksLastIndex);

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
                      _myBlocksLastIndex = 10;
                      _myBlocksTotalCountInDB -= 1;
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
      } else if (_currentTabIndex == 1 &&
          _myLikes.length < _myLikesTotalCountInDB) {
        MusicApi.getVideosFor('likes', _user.id, _myLikesLastIndex).then((res) {
          setState(() {
            _myLikes.addAll(res["posts"]);
            _myLikesLastIndex += 10;
          });
        });
      } else if (_currentTabIndex == 2 &&
          _myBlocks.length < _myBlocksTotalCountInDB) {
        MusicApi.getVideosFor('blocks', _user.id, _myBlocksLastIndex)
            .then((res) {
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
                  itemBuilder: (context, index) {
                    return Container(
                        height: 90,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: Row(children: [
                          ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: 113, maxHeight: 70),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white54, width: 0.5)),
                                width: 113,
                                height: 67,
                                child: Stack(children: [
                                  items[index]['thumbnailUrl'] != null
                                      ? Center(
                                          child: GestureDetector(
                                              onTap: () {
                                                if (type == "myBlocks")
                                                  _showDialog(
                                                      items[index]["_id"]);
                                                else
                                                  setState(() {
                                                    _currentlySelectedPlayList =
                                                        items;
                                                    _currentlyPlayingIndex =
                                                        index;
                                                    _musicActivated = true;
                                                  });
                                              },
                                              child: Image.network(items[index]
                                                  ['thumbnailUrl'])))
                                      : Center(
                                          child: GestureDetector(
                                              onTap: () {
                                                if (type == "myBlocks")
                                                  _showDialog(
                                                      items[index]["_id"]);
                                                else
                                                  setState(() {
                                                    _currentlySelectedPlayList =
                                                        items;
                                                    _currentlyPlayingIndex =
                                                        index;
                                                    _musicActivated = true;
                                                  });
                                              },
                                              child: Image.network(
                                                  "https://ik.imagekit.io/kitkitkitit/tr:q-100,w-106,h-62/thumbnail-default.jpg"))),
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
                                                            220, 100, 128, 1))))
                                          ])))
                                      : type == "myBlocks"
                                          ? Center(
                                              child: IconButton(
                                                  icon: Icon(Icons.block),
                                                  color: Color.fromRGBO(
                                                      255, 0, 0, 1),
                                                  iconSize: 50,
                                                  onPressed: () => _showDialog(
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
                                          else
                                            setState(() {
                                              _currentlySelectedPlayList =
                                                  items;
                                              _currentlyPlayingIndex = index;
                                              _musicActivated = true;
                                            });
                                        },
                                        child: Text("${items[index]["title"]}",
                                            style: TextStyle(
                                                color: Colors.white))),
                                  ])))
                        ]));
                  })),
        ]));
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text("Are you sure you want to sign out?",
              style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Yes", style: TextStyle(fontSize: 20)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                FlutterSecureStorage().deleteAll();
                _singleton.user = null;
                _singleton.clicked = 0;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => AppScreen()),
                    (_) => false);
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget floatingYoutubeScreen = Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * .56,
        child: Stack(children: [
          YoutubePlayer(
            context: context,
            videoId: YoutubePlayer.convertUrlToId(_currentlySelectedPlayList
                        .isNotEmpty &&
                    _currentlySelectedPlayList[_currentlyPlayingIndex] != null
                ? _currentlySelectedPlayList[_currentlyPlayingIndex]['videoUrl']
                : "https://youtu.be/HoXNpjUOx4U"),
            flags: YoutubePlayerFlags(
              disableDragSeek: true,
              autoPlay: true,
              mute: false,
              showVideoProgressIndicator: true,
            ),
            videoProgressIndicatorColor: Colors.amber,
            progressColors: ProgressColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent,
            ),
            onPlayerInitialized: (controller) {
              _controller = controller;
              _controller.cue();
              _controller.addListener(() {
                if (_controller.value.isFullScreen) {
                  _singleton.isFullScreen = true;
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.landscapeLeft]);
                } else {
                  _singleton.isFullScreen = false;
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                }
                if (_controller.value.playerState == PlayerState.PAUSED) {
                  setState(() {
                    _isPaused = true;
                  });
                }
                if (_controller.value.playerState == PlayerState.PLAYING) {
                  setState(() {
                    _isPaused = false;
                  });
                }
                if (_controller.value.playerState == PlayerState.UNKNOWN) {
                  _controller.cue();
                }
                if (_controller.value.playerState == PlayerState.ENDED) {
                  _isRepeatOn
                      ? _controller.cue()
                      : _currentlyPlayingIndex <
                              _currentlySelectedPlayList.length - 1
                          ? setState(() {
                              _currentlyPlayingIndex += 1;
                            })
                          : _isRepeatAllOn
                              ? setState(() {
                                  _currentlyPlayingIndex = 0;
                                })
                              : _controller.pause();
                }
                if (_controller.value.playerState == PlayerState.CUED) {
                  _controller.play();
                }
                if (_controller.value.hasError) {
                  print("Error: ${_controller.value.errorCode}");
                  if (_controller.value.errorCode == 150) {
                    setState(() {
                      _currentlySelectedPlayList[_currentlyPlayingIndex]
                          ['videoUrl'] = "https://youtu.be/HoXNpjUOx4U";
                    });
                  }
                }
              });
            },
          ),
          _isPaused
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * .56,
                  foregroundDecoration: _isPaused
                      ? BoxDecoration(color: Colors.black45)
                      : BoxDecoration(),
                )
              : Container(),
          _isPaused
              ? Positioned(
                  top: MediaQuery.of(context).size.width * .56 * .5 - 30,
                  left: MediaQuery.of(context).size.width * .5 - 150,
                  child: Container(
                      width: 60,
                      height: 60,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        textColor: Color.fromRGBO(255, 255, 255, 1),
                        child: Icon(Icons.archive, size: 50),
                        color: Colors.transparent,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  titlePadding: EdgeInsets.all(0),
                                    contentPadding: EdgeInsets.all(0),
                                    title: Container(
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(width: 0.3))
                                      ),
                                      padding: EdgeInsets.all(14),
                                        child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 5),
                                              child: Text("My Play Lists",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          Text(
                                              "Choose a play list to save the video",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.normal))
                                        ])),
                                    content: ConstrainedBox(
                                        constraints:
                                            BoxConstraints(minHeight: 150, maxHeight: 250),
                                        child: ListView.separated(
                                            itemCount: _myPlayLists.length,
                                            separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.black),
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                  leading: Text("${index+1}: ", style: TextStyle(color: Colors.blueGrey),),
                                                  title: Text(
                                                      _myPlayLists[index]
                                                          ['title'],
                                                      style: TextStyle(
                                                          color: Colors.blueGrey)),
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                              title: Text(
                                                                  "Do you want to save the video to play list: "),
                                                              content: Text("\"${_myPlayLists[index]['title']}\""),
                                                              actions: [
                                                                new FlatButton(
                                                                    child: new Text(
                                                                        "Yes",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20)),
                                                                    onPressed:
                                                                        () {
                                                                          PlayListApi.addMusicToPlayList(_currentlySelectedPlayList[_currentlyPlayingIndex]['_id'], _myPlayLists[index]['_id']).then((responseCode){
                                                                            if (responseCode == 200) {
                                                                              Navigator.of(context).pop();
                                                                              Navigator.of(context).pop();
                                                                            }
                                                                            else {
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return AlertDialog(
                                                                                    title: Text("The video already exists in the play list"),
                                                                                    actions: [
                                                                                      new FlatButton(
                                                                                        child: new Text(
                                                                                          "Okay"
                                                                                        ),onPressed: (){
                                                                                          Navigator.of(context).pop();
                                                                                          Navigator.of(context).pop();
                                                                                      },
                                                                                      )
                                                                                    ]
                                                                                  );
                                                                                },
                                                                              );
                                                                            }
                                                                          });
                                                                        }),
                                                                new FlatButton(
                                                                    child: new Text(
                                                                        "No",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20)),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    })
                                                              ]);
                                                        });
                                                  });
                                            })),
                                    actions: <Widget>[
                                      new FlatButton(
                                        child: new Text('CANCEL'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ]);
                              });
                        },
                      )))
              : Container(),
          _isPaused
              ? Positioned(
                  top: MediaQuery.of(context).size.width * .56 * .5 - 30,
                  left: MediaQuery.of(context).size.width * .5 - 90,
                  child: Container(
                      width: 60,
                      height: 60,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        textColor: Color.fromRGBO(255, 255, 255, 1),
                        child: Icon(Icons.photo_size_select_large, size: 50),
                        color: Colors.transparent,
                        onPressed: () {},
                      )))
              : Container(),
          _isPaused
              ? Positioned(
                  top: MediaQuery.of(context).size.width * .56 * .5 - 30,
                  left: MediaQuery.of(context).size.width * .5 - 30,
                  child: Container(
                      width: 60,
                      height: 60,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        textColor: Color.fromRGBO(255, 255, 255, 1),
                        child: Icon(Icons.play_arrow, size: 60),
                        color: Colors.transparent,
                        onPressed: () {
                          _controller.play();
                        },
                      )))
              : Container(),
          _isPaused
              ? Positioned(
                  top: MediaQuery.of(context).size.width * .56 * .5 - 30,
                  left: MediaQuery.of(context).size.width * .5 + 30,
                  child: Container(
                      width: 60,
                      height: 60,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        textColor: Color.fromRGBO(255, 255, 255, 1),
                        child: Icon(Icons.repeat_one, size: 50),
                        color: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            _isRepeatOn = !_isRepeatOn;
                          });
                        },
                      )))
              : Container(),
          _isPaused
              ? Positioned(
                  top: MediaQuery.of(context).size.width * .56 * .5 - 30,
                  left: MediaQuery.of(context).size.width * .5 + 90,
                  child: Container(
                      width: 60,
                      height: 60,
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        textColor: Color.fromRGBO(255, 255, 255, 1),
                        child: Icon(Icons.repeat, size: 50),
                        color: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            _isRepeatAllOn = !_isRepeatAllOn;
                          });
                        },
                      )))
              : Container(),
          _isRepeatOn
              ? Positioned(
                  top: MediaQuery.of(context).size.width * .56 * .1,
                  right: 30,
                  child: Container(
                      child: Container(
                    child:
                        Icon(Icons.repeat_one, size: 20, color: Colors.white),
                  )))
              : Container(),
          _isRepeatAllOn
              ? Positioned(
                  top: MediaQuery.of(context).size.width * .56 * .1,
                  right: 10,
                  child: Container(
                      child: Container(
                    child: Icon(Icons.repeat, size: 20, color: Colors.white),
                  )))
              : Container(),
        ]));
    return FutureBuilder(
        future: _fetchMyPosts,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                backgroundColor: Color.fromRGBO(27, 25, 35, .8),
                body: Stack(children: [
                  Column(children: [
                    _musicActivated
                        ? floatingYoutubeScreen
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width * .56,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                        "https://ik.imagekit.io/kitkitkitit/tr:q-100,ar-16-9,w-400/default_bg.jpg"),
                                    fit: BoxFit.cover))),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.255,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(22, 25, 32, 1),
                                Color.fromRGBO(40, 37, 56, 1),
                              ]),
                        ),
                        child: Stack(children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    height: MediaQuery.of(context).size.height *
                                            0.255 -
                                        60,
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .4,
                                              child: Center(
                                                  child: Container(
                                                      width: MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          .14,
                                                      height: MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          .14,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color.fromRGBO(
                                                              70, 70, 80, 1)),
                                                      child: IconButton(
                                                          icon: Icon(Icons.photo_camera, color: Colors.white70),
                                                          iconSize: 35,
                                                          onPressed: null)))),
                                          Container(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                Container(
                                                    child: Text(
                                                        _user != null
                                                            ? _user.nickname
                                                            : "",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "NotoSans",
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white))),
                                                Container(
                                                    child: Text(
                                                        _user != null
                                                            ? "${_user.followers} Followers"
                                                            : "?",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontFamily:
                                                                "NotoSans",
                                                            color:
                                                                Colors.white))),
                                                Container(
                                                    child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                      Text("$totalLikes Likes ",
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  "BalooChettan",
                                                              color: Color
                                                                  .fromRGBO(
                                                                      220,
                                                                      100,
                                                                      128,
                                                                      1))),
                                                      Text("on my posts",
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  "NotoSans",
                                                              color:
                                                                  Colors.white))
                                                    ]))
                                              ])),
                                        ])),
                                Container(
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
                                                  ? Text(
                                                      "$_myPostsTotalCountInDB",
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
                                                  ? Text(
                                                      "$_myLikesTotalCountInDB",
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
                                                  ? Text(
                                                      "$_myBlocksTotalCountInDB",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              247, 221, 68, 1)))
                                                  : Container()
                                            ])),
                                      ],
                                    )),
                              ]),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: RaisedButton.icon(
                                elevation: 0,
                                textColor: Color.fromRGBO(255, 255, 255, .8),
                                label: Text("Sign out",
                                    style: TextStyle(fontSize: 12)),
                                icon: Icon(Icons.exit_to_app, size: 16),
                                color: Colors.transparent,
                                onPressed: () {
                                  _signOut();
                                },
                              ))
                        ])),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.65 -
                            0.45 * MediaQuery.of(context).size.width,
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
                  ]),
//                  Center(child: Draggable(
//                    childWhenDragging: Container(),
//                      feedback: floatingYoutubeScreen,
//                      child: floatingYoutubeScreen))
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
            return Center(
                child: Text("${snapshot.connectionState}",
                    style: TextStyle(color: Colors.white, fontSize: 10)));
          }
        });
  }
}
