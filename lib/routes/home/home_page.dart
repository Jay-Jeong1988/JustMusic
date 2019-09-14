import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/models/user.dart';
import 'package:JustMusic/routes/home/components/youtube_player.dart';
import 'package:JustMusic/utils/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class HomePage extends StatefulWidget {
  final List<dynamic> selectedCategories;
  final List<dynamic> inheritedSources;
  HomePage({Key key, this.selectedCategories, this.inheritedSources});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollPhysics _pageViewScrollPhysics;
  final _pageController = PageController(initialPage: 0, keepPage: false);
  PageView pageView;
  List<dynamic> _sources = [];
  Future<List<dynamic>> _urlConverted;
  List<String> _categoryTitles = [];
  User _user;
  Singleton _singleton = Singleton();
  bool _inheritedFromPlayList = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategories != null) {
      _categoryTitles.addAll(widget.selectedCategories.map((category) {
        return category['title'];
      }));
    }
    _user = _singleton.user;
    _urlConverted = MusicApi.getMusics(_categoryTitles, userId: _user != null ? _user.id : null);
    if(widget.inheritedSources != null) setState((){_inheritedFromPlayList = true;});
    _urlConverted.then((musics) {
      _sources = widget.inheritedSources ?? musics;
    });
  }

  List shuffle(List items) {
    var random = new Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

//  void _scrollOn() async {
//    _pageViewScrollPhysics = NeverScrollableScrollPhysics();
//    await Future.delayed(const Duration(milliseconds: 1000));
//    setState((){
//      _pageViewScrollPhysics = AlwaysScrollableScrollPhysics();
//    });
//  }

  void resetSources(blockedMusicId) async{
      _sources.removeWhere((source){
        return source['_id'] == blockedMusicId;
      });
    _pageController.previousPage(duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: 200), () => _pageController.nextPage(duration: Duration(milliseconds: 100), curve: Curves.easeInOut));
    setState(() {
      _sources = _sources;
    });
  }

  Widget _pageBuilder(){
    return FutureBuilder(
        future: _urlConverted,
        builder: (BuildContext context, snapshot)
    {
      if (snapshot.hasData) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _sources.isNotEmpty
              ? PageView(
              physics: _pageViewScrollPhysics,
              controller: _pageController,
              scrollDirection: Axis.vertical,
              pageSnapping: true,
              onPageChanged: (index) {
//                setState(() {
//                  _scrollOn();
//                });
                if (index >= _sources.length - 1 && !_inheritedFromPlayList) {
                  MusicApi.getMusics(_categoryTitles, userId: _user != null ? _user.id : null).then((musics){
                    setState(() {
                      _sources..addAll(musics);
                    });
                  });
                }
              },
              children: []
                ..addAll(_sources.map((_source) {
                  return YoutubePlayerScreen(
                      source: _source,
                      pageController: _pageController,
                      user: _user,
                      resetSources: resetSources);
                })))
              : Stack(children: [
            Positioned(
                top: MediaQuery
                    .of(context)
                    .size
                    .height * .02,
                child:
                Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Center(child:
                    Container(
                        child: Image.asset('assets/images/justmusic_logo.png'),
                        width: 140))
                )),
            Center(
                child: Text(
                    "Found an empty play list.\nPlease choose genre(s) or another play list\nand try again !",
                    style: TextStyle(color: Colors.white)))
          ]);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
          _pageBuilder(),
          _singleton.tutorialStatus["homePage"] ? Positioned.fill(child: HomePageTutorialScreen()) : Container()
        ])
    );
  }
}

class HomePageTutorialScreen extends StatefulWidget {
  createState() => HomePageTutorialScreenState();
}

class HomePageTutorialScreenState extends State<HomePageTutorialScreen> {
  Singleton _singleton = Singleton();
  bool _isFinished = false;

  Future<void> _saveTutorialStatusToDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("tutorialStatus", jsonEncode(_singleton.tutorialStatus));
  }

  @override
  Widget build(BuildContext context) {
    return _isFinished ? Container() : GestureDetector(
        onTap: (){
          _singleton.tutorialStatus["homePage"] = false;
          _saveTutorialStatusToDisk().then((v){
            setState(() {
              _isFinished = true;
            });
          });
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                color: Colors.black87
            ),
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(children: [
                  Positioned(
                      top: MediaQuery.of(context).size.height * .1 + 130,
                      left: MediaQuery.of(context).size.width * .9 - 280,
                      child: Container(
                          width: 210,
                          height: 50,
                          child: Text("Slide up/down\n to skip videos .", style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: "PermanentMarker"))
                      )
                  ),
                  Positioned(
                      top: MediaQuery.of(context).size.height * .1 + 220,
                      left: MediaQuery.of(context).size.width * .9 - 120,
                      child: Container(
                          width: 30,
                          height: 70,
                          child: SvgPicture.asset("assets/images/vertical-resizing-option.svg",
                            semanticsLabel: "A white up and down arrow",
                            fit: BoxFit.cover,
                          )
                      )
                  ),
                  Positioned(
                      left: MediaQuery.of(context).size.width * .5 - 70,
                      top: MediaQuery.of(context).size.height * .75,
                      child: Container(
                          width: 170,
                          height: 30,
                          child: Text("Tap to dismiss", style: TextStyle(color: Colors.white70, fontSize: 20, fontFamily: "PermanentMarker"))
                      )
                  ),
                ])
            )));
  }
}