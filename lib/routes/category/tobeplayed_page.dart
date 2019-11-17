import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/app_ads.dart';
import 'package:JustMusic/global_components/empty_widgets.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/models/user.dart';
import 'package:JustMusic/utils/logo.dart';
import 'package:JustMusic/utils/save_to_playlist_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../main.dart';

class ToBePlayedPage extends StatefulWidget {
  final List<dynamic> selectedCategories;
  ToBePlayedPage({Key key, this.selectedCategories});
  createState() => ToBePlayedPageState();
}

class ToBePlayedPageState extends State<ToBePlayedPage> with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;
  ScrollController _listViewScrollController;
  List<dynamic> _sources = [];
  String _textFieldValue = "";
  String _keyword = "";
  int _lastIndex = 0;
  Singleton _singleton = Singleton();
  Future<List<dynamic>> _urlConverted;
  List<String> _categoryTitles = [];
  User _user;
  int _currentlyPlayingIndex = 0;
  var _controller = YoutubePlayerController();
  bool _isPlaying = false;
  static const MethodChannel _channel = const MethodChannel('flutter_android_pip');
  static const MethodChannel _channel2 = const MethodChannel('flutter_android_pip2');
  bool _nativePlayBtnClicked = true;
  bool _isInPipMode = false;

  @override
  void initState(){
    WidgetsBinding.instance.addObserver(this);
    _listViewScrollController = new ScrollController()
      ..addListener(_scrollListener);

    if (widget.selectedCategories != null) {
      _categoryTitles.addAll(widget.selectedCategories.map((category) {
        return category['title'];
      }));
    }
    _user = _singleton.user;
    _urlConverted = MusicApi.getMusics(_categoryTitles, userId: _user != null ? _user.id : null);
    _urlConverted.then((musics) {
      _sources = musics;
    });
  
    _showAd();
    _channel.setMethodCallHandler(_didReceiveTranscript);
    _channel2.setMethodCallHandler(_didReceiveTranscript2);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.play();
      _lastLifecycleState = state;
      print("Last life cycle state: $_lastLifecycleState");
      if(_lastLifecycleState == AppLifecycleState.inactive) {
        if(_nativePlayBtnClicked) _controller.play();
        else _controller.pause();
        setState(() {
          _isInPipMode = true;
        });
      }else if(_lastLifecycleState == AppLifecycleState.resumed){
        setState(() {
          _isInPipMode = false;
        });
      }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _showAd() async {
    await Future.delayed(const Duration(milliseconds: 500));
    AppAds.init(bannerUnitId: 'ca-app-pub-7258776822668372/7065456288');
    AppAds.showBanner();
    _singleton.adSize = "full";
  }

  void _scrollListener() {
    if (_listViewScrollController.position.extentAfter <= 0) {
      MusicApi.getMusics(_categoryTitles, userId: _user != null ? _user.id : null).then((musics){
        setState(() {
          _sources..addAll(musics);
        });
      });
    }
  }


  Widget _searchField() {
    return Container(
        padding: EdgeInsets.fromLTRB(23.0, 10.0, 23.0, 10.0),
        child: Row(
            children: <Widget> [
              Container(
                  width: MediaQuery.of(context).size.width * .65,
                  child: TextField(
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: "Keyword",
                        contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(145, 145, 155, 1.0),
                                width: 1.5)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(185, 185, 195, 1.0),
                                width: 1.5)),
                        filled: true,
                        fillColor: Color.fromRGBO(75, 75, 85, 1.0)),
                    onChanged: (val){
                      setState((){
                        _textFieldValue = val;
                      });
                    },
                  )),
              Flexible(
                  child: Container(
                      child: FlatButton(
                        padding: EdgeInsets.symmetric(vertical: 7.0),
                        color: Colors.blueGrey,
                        child: Icon(Icons.search, color: Color.fromRGBO(255, 255, 255, .7), size: 30.0),
                        onPressed: (){
                          _keyword = _textFieldValue;
                          if (_keyword != "" && _keyword.replaceAll(RegExp(r"\s"), "").length != 0) {
                            MusicApi.getSearchResult(_keyword, _lastIndex).then((result){
                              setState(() {
                                _isPlaying = false;
                                _currentlyPlayingIndex = 0;
                                _sources = result;
                                sendPlayingStatusToNative();
                              });
                            });
                          }else {
                            _urlConverted.then((musics) {
                              setState(() {
                                _isPlaying = false;
                                _currentlyPlayingIndex = 0;
                                _sources = musics;
                                sendPlayingStatusToNative();
                              });
                            });
                          }
                        },
                      )))
            ]));
  }

  Widget _listView(listItem) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(children: [
          Container(
              decoration: BoxDecoration(color: Colors.transparent),
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70),
                  controller: _listViewScrollController,
                  itemCount: _sources.length,
                  padding: EdgeInsets.only(top: 20, bottom: 50),
                  itemBuilder: (context, index) {
                    dynamic source = _sources[index];
                    return _sources.isEmpty ? EmptySearchWidget(textInput: "No result.") : listItem(source);
                  })),
        ]));
  }

  Widget _listItem(source) {
    var unescape = HtmlUnescape();
    String channelTitle = source["channelName"];
    String thumbnailUrl = source['thumbnailUrl'];
    String title = unescape.convert(source["title"]);
    String publishedAt = source["publishedAt"];
    String description = source["description"];
    return Container(
        height: MediaQuery.of(context).size.width * .23,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(child:
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54, width: 0.5),
                    image: DecorationImage(image: NetworkImage(thumbnailUrl), fit: BoxFit.cover)
                ),
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.width * 0.199,
              ),
                onTap: (){
                  setState(() {
                    _currentlyPlayingIndex = _sources.indexOf(source);
                    _isPlaying = true;
                    sendPlayingStatusToNative();
                  });
                },
              ),
              Expanded(
                  child: GestureDetector(
                      onTap: (){
                        setState(() {
                          _currentlyPlayingIndex = _sources.indexOf(source);
                          _isPlaying = true;
                          sendPlayingStatusToNative();
                        });
                      },
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        height: 1.0,
                                        fontSize: 12.5,
                                        color: Colors.white)),
                                Container(
                                    margin: EdgeInsets.only(top: 4.0),
                                    child: Text("$channelTitle · $publishedAt",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 9.0,
                                          color: Colors.white70
                                      ),
                                    )),
                                Container(
                                    margin: EdgeInsets.only(top: 4.0),
                                    child: Text(description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        height: 1.0,
                                        fontSize: 9.0,
                                        color: Color.fromRGBO(235, 235, 235, 1),
                                      ),
                                    ))
                              ])))),
              GestureDetector(
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              content: SingleChildScrollView(child: Container(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(source["title"], style: TextStyle(fontSize: 20)),
                                  Container(
                                      width: MediaQuery.of(context).size.width * .7, child: FlatButton(
                                          child: Text("Play"),
                                          padding: EdgeInsets.all(0),
                                          color: Colors.transparent,
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                            setState(() {
                                              _currentlyPlayingIndex = _sources.indexOf(source);
                                              _isPlaying = true;
                                              sendPlayingStatusToNative();
                                            });
                                          }
                                        )),
                                  SaveToPlayListButton(
                                  currentlyPlaying: source,
                                      saveIcon: Icon(Icons.archive, size: 50, color: Colors.black),
                                  label: "Save to Playlists"),
                                  Container(
                                      width: MediaQuery.of(context).size.width *.7,child: FlatButton(
                                            child: Text("Block"),
                                            padding: EdgeInsets.all(0),
                                            color: Colors.transparent,
                                            onPressed: (){
                                              MusicApi.perform(
                                              "block", _user.id, source["_id"])
                                                  .then((j) {
                                              setState(() {
                                                _sources.removeWhere((iterable) {
                                                  return iterable["_id"] == source["_id"];
                                                });
                                              });
                                              Navigator.of(context).pop();
                                            });}
                                        )),
                                  Container(
                                      width: MediaQuery.of(context).size.width * .7,
                                        child: FlatButton(
                                            child: Text("Cancel"),
                                            padding: EdgeInsets.all(0),
                                            color: Colors.transparent,
                                            onPressed: ()=>Navigator.of(context).pop()
                                        )),
                                      ]))),
                              contentPadding: EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 0),
                          );
                        });},
                  child: Container(
                      margin: EdgeInsets.only(left: 3.0),
                      child: Icon(Icons.more_vert, color: Colors.white70)
                  ))
            ]));
  }

  Widget _youtubePlayer() {
    return Container(
        width: MediaQuery.of(context).size.width * .9
        ,
    height: MediaQuery.of(context).size.width * .504,
    child:
    YoutubePlayer(
      globalKey: true,
      context: context,
      videoId: YoutubePlayer.convertUrlToId(
          _sources.isNotEmpty &&
              _sources[_currentlyPlayingIndex] != null
              ? _sources[_currentlyPlayingIndex]['videoUrl']
              : "https://youtu.be/HoXNpjUOx4U"),
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
            if(_lastLifecycleState == AppLifecycleState.inactive && _nativePlayBtnClicked) {
              _controller.play();
            }
          }
          if (_controller.value.playerState == PlayerState.PLAYING) {
          }
          if (_controller.value.playerState == PlayerState.UNKNOWN) {
            _controller.cue();
          }
          if (_controller.value.playerState == PlayerState.ENDED) {
            _currentlyPlayingIndex < _sources.length - 1
                ? setState(() {
                  _currentlyPlayingIndex += 1;
                  })
                : setState(() {
                    _currentlyPlayingIndex = 0;
                  });
            _controller.cue();
          }
          if (_controller.value.playerState == PlayerState.CUED) {
            _controller.play();
          }
          if (_controller.value.hasError) {
            print("Error: ${_controller.value.errorCode}");
            if (_controller.value.errorCode == 150) {
              setState(() {
                _sources[_currentlyPlayingIndex]['videoUrl'] =
                "https://youtu.be/HoXNpjUOx4U";
              });
            }
          }
        });
      },
    ));
  }


  double top = 0;
  double left = 0;
  bool dragging = false;

  Widget videoPlayingWindow() {
    return Container(
      alignment: Alignment.topLeft,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child:
      Draggable(
        childWhenDragging: Container(),
          feedback: Container(child: _youtubePlayer(), padding: EdgeInsets.only(top: top, left: left)),
          child: Container(padding: EdgeInsets.only(top: top, left: left), child: _youtubePlayer()),
        onDragStarted: () {
          setState(() {
            dragging = true;
          });
        },
        onDragEnd: (drag) {
          setState(() {
            dragging = false;
            top = top + drag.offset.dy < 0 ? 0 : top + drag.offset.dy;
            left = left + drag.offset.dx < 0 ? 0 : left + drag.offset.dx;
          });
        },
      )
    );
  }

  Color _dragTargetColor = Colors.black87;

  Future<void> sendPlayingStatusToNative() async {
    String response = "";
    try {
      final String result = await _channel.invokeMethod('playingStatus', {"isPlaying": _isPlaying});
      response = result;
      } on PlatformException catch (e) {
        response = "Failed to Invoke: '${e.message}'.";
      }
      print(response);
  }

  Future<void> _didReceiveTranscript(MethodCall call) async {
    final String utterance = call.arguments;
    switch(call.method) {
      case "didReceiveTranscript":
        print(utterance);
        setState(() {
          if (utterance == "playButtonClicked") {
            _nativePlayBtnClicked = true;
            _controller.play();
          }
        });
    }
  }
  Future<void> _didReceiveTranscript2(MethodCall call) async {
    final String utterance = call.arguments;
    switch(call.method) {
      case "didReceiveTranscript2":
        print(utterance);
        setState(() {
          if (utterance == "pauseButtonClicked") {
            _nativePlayBtnClicked = false;
            _controller.pause();
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _urlConverted,
        builder: (BuildContext context, snapshot)
    {
      if (snapshot.hasData) {
        if (snapshot.connectionState == ConnectionState.done) {
          return !_isInPipMode ?
            SingleChildScrollView(
                child: Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(20, 23, 41, 1),
                              Color.fromRGBO(50, 47, 61, 1),
                              Color.fromRGBO(50, 67, 81, 1),
                              Color.fromRGBO(50, 87, 101, 1),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            tileMode: TileMode.clamp)),
                    child: Scaffold(
                        appBar: EmptyAppBar(),
                        body: Stack(children: [
                        Container(
                            child: Column(children: <Widget>[
                              Row(mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text("Playing Videos",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold)))
                                  ]),
                              _searchField(),
                              Flexible(child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      5.0, 0, 5.0, 110.0),
                                  child: _listView(_listItem)
                              ))
                            ])
                        ),
                          dragging ?
                          Positioned(
                            bottom: 0,
                              child: DragTarget(
                            builder: (BuildContext context, incoming, rejected) {
                              return Container(
                                color: _dragTargetColor,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * .1,
                                child: Center(child: Icon(Icons.close, color: Colors.white60, size: 50.0))
                              );
                            },
                                onLeave: (data) {
                                  setState(() {
                                    _dragTargetColor = Colors.black87;
                                  });
                                },
                            onWillAccept: (data) {
                              setState(() {
                                _dragTargetColor = Color.fromRGBO(60, 60, 60, .7);
                              });
                              return true;
                            }, onAccept: (data) {
                              setState((){
                                _isPlaying = false;
                                _dragTargetColor = Colors.black87;
                                sendPlayingStatusToNative();
                              });
                            },
                          )) : Container(),
                          _isPlaying ? videoPlayingWindow()
                              : Container(),
                    ])))) :
              _youtubePlayer()
          ;
      }else if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: Logo());
      } else {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 14.0, color: Colors.white)),
                  RaisedButton(
                      onPressed: () =>
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    AppScreen()),
                          ),
                      child: Text("Exit"),
                      textColor: Colors.white,
                      elevation: 7.0,
                      color: Colors.transparent)
                ]));
      }
    } else {
    return Container();
    }
});
  }
}