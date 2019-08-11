import 'dart:async';

import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  YoutubePlayerScreen(
      {Key key, @required this.resetSources, @required this.user, @required this.source, @required this.pageController});

  final PageController pageController;
  final dynamic source;
  final user;
  final resetSources;

  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen>
    with WidgetsBindingObserver {
  var _controller = YoutubePlayerController();
  dynamic source;
  bool _isRepeatOn = false;
  bool _liked = false;
  bool _isSaving = false;
  bool _blocked = false;
  List<String> alternative = [];
  Singleton _singleton = new Singleton();
  DateTime _currentUtilBtnTappedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    source = widget.source;
    alternative.add(widget.source["videoUrl"]);
    checkLikes();
    checkBlocks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void autoSwipe(PageController pageController) {
    setState(() {
      pageController.nextPage(
          duration: Duration(milliseconds: 1000), curve: Curves.decelerate);
    });
  }

  Widget _repeatButton() {
    return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 50),
        child: FlatButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _isRepeatOn = _isRepeatOn == false ? true : false;
              });
            },
            textColor: _isRepeatOn == false ? Colors.white30 : Colors.white,
            child: Column(
                children: [Icon(Icons.repeat_one, size: 40), Text("Repeat")])));
  }

  Widget _iconButton(name, statusVar) {
    Map<String, Color> colors = {
      "Like": Color.fromRGBO(233, 30, 98, 1),
      "Save": Color.fromRGBO(20, 155, 255, 1),
      "Block": Color.fromRGBO(255, 0, 0, 1),
      "LikeDisabled": Color.fromRGBO(233, 30, 98, .5),
      "SaveDisabled": Color.fromRGBO(20, 155, 255, .5),
      "BlockDisabled": Color.fromRGBO(255, 0, 0, .5),
    };
    Map<String, Icon> icons = {
      "Like": Icon(Icons.favorite, size: 30),
      "Save": Icon(Icons.library_music, size: 30),
      "Block": Icon(Icons.block, size: 30),
      "LikeDisabled": Icon(Icons.favorite_border, size: 30),
      "SaveDisabled": Icon(Icons.library_add, size: 30),
      "BlockDisabled": Icon(Icons.block, size: 30)
    };

    return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 50),
        child: Container(
            margin: EdgeInsets.only(bottom: 5),
            child: FlatButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (widget.user != null) {
                    setState(() {
                      switch (name) {
                        case "Like":
                          _liked ? MusicApi.perform(
                              "unlike", widget.user.id, source["_id"])
                              .then((j) {
                            setState(() {
                              _liked = false;
                            });
                          })
                              : MusicApi.perform(
                              "like", widget.user.id, source["_id"])
                              .then((j) {
                            setState(() {
                              _liked = true;
                            });
                          });
                          break;
                        case "Save":
                          setState(() {
                            _isSaving = _isSaving == false ? true : false;
                          });
                          break;
                        case "Block":
                          _blocked ? MusicApi.perform(
                              "unblock", widget.user.id, source["_id"])
                              .then((j) {
                            setState(() {
                              _blocked = false;
                            });
                          })
                              : MusicApi.perform(
                              "block", widget.user.id, source["_id"])
                              .then((j) {
                            setState(() {
                              _blocked = true;
                            });
                            widget.resetSources();
                          });
                          print("blocked: $_blocked");
                      }
                    });
                  }else {
                    DateTime now = DateTime.now();
                    if (_currentUtilBtnTappedTime == null ||
                        now.difference(_currentUtilBtnTappedTime) > Duration(seconds: 3)) {
                      _currentUtilBtnTappedTime = now;
                      Fluttertoast.showToast(
                          msg: "You need to log in",
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Color.fromRGBO(0, 0, 0, 0.5)
                      );
                    }
                    print("user is null");
                  }
                },
                textColor: statusVar == false
                    ? colors["${name}Disabled"]
                    : colors[name],
                child: Column(children: [
                  statusVar == false ? icons["${name}Disabled"] : icons[name],
                  Text(name)
                ]))));
  }

  var reload = false;

  void _scrollOn() async {
    reload = true;
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      reload = false;
    });
  }

  bool _isReadMore = true;

  void checkLikes (){
    if(widget.user != null) {
      MusicApi.check("isLiked", widget.user.id, source["_id"])
          .then((result) {
        setState(() {
          print("liked: ${result['isLiked']}");
          _liked = result['isLiked'];
        });
      });
    }
  }

  void checkBlocks (){
    if(widget.user != null) {
      MusicApi.check("isBlocked", widget.user.id, source["_id"])
          .then((result) {
        setState(() {
          print("blocked: ${result['isBlocked']}");
          _blocked = result['isBlocked'];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> descriptionArray = source["description"].split(" ");
    String shortenedDescription = "";
    for(var i = 0; i < 5; i++) {
      if (descriptionArray.length > i) {
        shortenedDescription += "${descriptionArray[i]} ";
        if (i == 4) shortenedDescription += "...";
      }
    }
    return Scaffold(
      backgroundColor: Color.fromRGBO(10, 10, 15, 1),
        body: Material(
      child: Stack(children: [
        Positioned(
            top: MediaQuery.of(context).size.height * .02,
            child:
            Container(
                width: MediaQuery.of(context).size.width,
                child: Center(child:
                Container(child: Image.asset('assets/images/justmusic_logo.png'),
                width: 140))
            )),
        Positioned(
            top: MediaQuery.of(context).size.height * .3,
            child: Container(
                child: FlatButton(
                    onPressed: () {},
                    textColor: Colors.white70,
                    child: Text(
                        "JustMusic publisher: "
                        "${source["uploader"] != null ? source["uploader"]["nickname"] : "unknown"}",
                        style: TextStyle(fontSize: 12))))),
        Positioned(
            top: MediaQuery.of(context).size.height * .25,
            left: MediaQuery.of(context).size.width * .82,
            child: Container(child: _repeatButton())),
        Positioned(
            top: MediaQuery.of(context).size.height * .67,
            left: MediaQuery.of(context).size.width * .82,
            child: Column(children: [
              Container(child: _iconButton("Like", _liked)),
              Container(child: _iconButton("Save", _isSaving)),
              Container(child: _iconButton("Block", _blocked)),
            ])),
        Center(
          child: reload == false
              ? YoutubePlayer(
                  context: context,
                  videoId: YoutubePlayer.convertUrlToId(source["videoUrl"]),
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
                      } else {
                        _singleton.isFullScreen = false;
                        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                      }
                      if (_controller.value.playerState == PlayerState.UNKNOWN) {
                        _controller.cue();
                      }
                      if (_controller.value.playerState == PlayerState.ENDED) {
                        _isRepeatOn == true
                            ? _controller.cue()
                            : autoSwipe(widget.pageController);
                      }
                      if (_controller.value.playerState == PlayerState.CUED) {
                        _controller.play();
                      }
                      if (_controller.value.hasError) {
                        print("Error: ${_controller.value.errorCode}");
                        if (_controller.value.errorCode == 2) {
                          setState(() {
                            _scrollOn();
                          });
                        } else {
                          setState(() {
                            source["videoUrl"] = "https://youtu.be/HoXNpjUOx4U";
                          });
                        }
                      }
                    });
                  },
                )
              : Container(),
        ),
        Positioned(
            top: MediaQuery.of(context).size.height * .66,
            left: MediaQuery.of(context).size.width * .03,
            child: Container(
                width: MediaQuery.of(context).size.width * .6,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * .12),
                          child: Container(
                              padding: EdgeInsets.only(bottom: 7),
                              child: Text(source["title"],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "NotoSans",
                                      fontSize: 15)))),
                      _isReadMore
                          ? Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Text(shortenedDescription,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "NotoSans",
                                          fontSize: 10)),
                                  FlatButton(
                                    padding: EdgeInsets.all(0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3, vertical: 1),
                                      child: Text("Open Description"),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: .5)),
                                    ),
                                    textColor: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        _isReadMore = false;
                                      });
                                    },
                                  )
                                ]))
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * .08),
                              child: SingleChildScrollView(
                                  child: Container(
                                      padding: EdgeInsets.only(bottom: 7),
                                      child: Text(source["description"],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "NotoSans",
                                              fontSize: 10))))),
                      Container(
                          child: Text("Published at: ${source["publishedAt"]}",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: "NotoSans",
                                  fontSize: 10))),
                      Container(
                          child: Text("Channel: ${source["channelName"]}",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: "NotoSans",
                                  fontSize: 10)))
                    ]))),
      ]),
    ));
  }
}
