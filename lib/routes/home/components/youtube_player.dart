import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  PageController _pageController;
  dynamic _source;
  YoutubePlayerScreen(this._source, this._pageController);

  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  var _controller = YoutubePlayerController();
  dynamic _source;
  bool _isRepeatOn = false;
  bool _liked = false;
  bool _reported = false;
  bool _blocked = false;

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.white54, Colors.white],
  ).createShader(Rect.fromLTWH(80.0, 0.0, 200, 70.0));

  void initState() {
    _source = widget._source;
  }

  void autoSwipe(PageController pageController) {
    setState(() {
      pageController.nextPage(
          duration: Duration(milliseconds: 1000), curve: Curves.decelerate);
    });
  }

  Widget _repeatButton() {
    return ConstrainedBox(constraints: BoxConstraints(
        maxWidth: 50
    ), child: FlatButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          _isRepeatOn = _isRepeatOn == false ? true : false;
        });
      },
      textColor: _isRepeatOn == false ? Colors.white30 : Colors.white,
      child: Column(children: [Icon(
        Icons.repeat_one, size: 40
      ),Text("Repeat")]
    )));
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

    return ConstrainedBox(constraints: BoxConstraints(
      maxWidth: 50
    ),
        child: Container(margin: EdgeInsets.only(bottom: 5),child: FlatButton(padding: EdgeInsets.zero,
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
        textColor: statusVar == false ? colors["${name}Disabled"] : colors[name],
        child: Column(children: [
          statusVar == false ? icons["${name}Disabled"] : icons[name], Text(name)]))));
  }

  @override
  Widget build(BuildContext context) {
    print(_source);
    return Material(
      child: Stack(children: [
        Positioned(
            top: MediaQuery.of(context).size.height * .05,
//            left: MediaQuery.of(context).size.width * .82,
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
                    child: Text("JUST MUSIC",
                        style: TextStyle(
                            foreground: Paint()..shader = linearGradient,
                            fontFamily: "NotoSans",
                            fontSize: 20))))),
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
          child: YoutubePlayer(
            context: context,
            videoId: YoutubePlayer.convertUrlToId(_source["videoUrl"]),
            flags: YoutubePlayerFlags(
              autoPlay: false,
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
                if (_controller.value.playerState == PlayerState.ENDED) {
                  _isRepeatOn == true
                      ? _controller.cue()
                      : autoSwipe(widget._pageController);
                }
                if (_controller.value.playerState == PlayerState.CUED) {
                  _controller.play();
                }
                if (_controller.value.hasError) {
                  print("Error: ${_controller.value.errorCode}");
                  setState(() {
                    _source["videoUrl"] = "https://youtu.be/HoXNpjUOx4U";
                  });
                }
              });
            },
          ),
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
                              child: Text(_source["title"],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "NotoSans",
                                      fontSize: 15)))),
                      ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * .12),
                          child: Container(
                              padding: EdgeInsets.only(bottom: 7),
                              child: Text(_source["description"],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "NotoSans",
                                      fontSize: 10)))),
                      Container(
                          child: Text("Published at: ${_source["publishedAt"]}",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: "NotoSans",
                                  fontSize: 10))),
                      Container(
                          child: Text("Channel: ${_source["channelName"]}",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: "NotoSans",
                                  fontSize: 10)))
                    ]))),
      ]),
    );
  }
}
