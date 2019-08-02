import 'dart:async';

import 'package:JustMusic/global_components/singleton.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  YoutubePlayerScreen(
      {Key key, @required this.source, @required this.pageController});

  final PageController pageController;
  final dynamic source;

  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen>
    with WidgetsBindingObserver {
  var _controller = YoutubePlayerController();
  dynamic source;
  bool _isRepeatOn = false;
  bool _liked = false;
  bool _reported = false;
  bool _blocked = false;
  List<String> alternative = [];
  Singleton _singleton = new Singleton();

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.white54, Colors.white],
  ).createShader(Rect.fromLTWH(80.0, 0.0, 200, 70.0));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    source = widget.source;
    alternative.add(widget.source["videoUrl"]);
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
      "Report": Color.fromRGBO(255, 235, 59, 1),
      "Block": Color.fromRGBO(255, 0, 0, 1),
      "LikeDisabled": Color.fromRGBO(233, 30, 98, .5),
      "ReportDisabled": Color.fromRGBO(255, 235, 59, .5),
      "BlockDisabled": Color.fromRGBO(255, 0, 0, .5),
    };
    Map<String, Icon> icons = {
      "Like": Icon(Icons.favorite, size: 30),
      "Report": Icon(Icons.error, size: 30),
      "Block": Icon(Icons.block, size: 30),
      "LikeDisabled": Icon(Icons.favorite_border, size: 30),
      "ReportDisabled": Icon(Icons.error_outline, size: 30),
      "BlockDisabled": Icon(Icons.block, size: 30)
    };

    return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 50),
        child: Container(
            margin: EdgeInsets.only(bottom: 5),
            child: FlatButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    switch (name) {
                      case "Like":
                        _liked = _liked == false ? true : false;
                        break;
                      case "Report":
                        _reported = _reported == false ? true : false;
                        break;
                      case "Block":
                        _blocked = _blocked == false ? true : false;
                    }
                  });
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

  @override
  Widget build(BuildContext context) {
    String shortenedDescription = source["description"] != null
        ? "${source["description"].split(" ")[0]} "
            "${source["description"].split(" ")[1]} "
            "${source["description"].split(" ")[2]} "
            "${source["description"].split(" ")[3]} "
            "${source["description"].split(" ")[4]} ..."
        : "";
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
              Container(child: _iconButton("Report", _reported)),
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
