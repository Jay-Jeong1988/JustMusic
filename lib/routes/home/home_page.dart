import 'dart:async';
import 'dart:math';
import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/models/category.dart';
import 'package:JustMusic/routes/home/components/youtube_player.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  List<Category> selectedCategories;
  HomePage({Key key, this.selectedCategories});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollPhysics _pageViewScrollPhysics;
  final _pageController = PageController(initialPage: 0);
  PageView pageView;
  List<dynamic> _sources = [];
  Future<List<dynamic>> _urlConverted;
  List<String> _categoryTitles = [];

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.white54, Colors.white],
  ).createShader(Rect.fromLTWH(80.0, 0.0, 200, 70.0));

  @override
  void initState() {
    if (widget.selectedCategories != null) {
      _categoryTitles.addAll(widget.selectedCategories.map((category) {
        return category.title;
      }));
    }

    _urlConverted = MusicApi.getMusics(_categoryTitles);
    _urlConverted.then((musics) {
      _sources = shuffle(musics);
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

  void _scrollOn() async {
    _pageViewScrollPhysics = NeverScrollableScrollPhysics();
    await Future.delayed(const Duration(milliseconds: 800));
    setState((){
      _pageViewScrollPhysics = AlwaysScrollableScrollPhysics();
    });
  }

  Widget _pageBuilder(){
    return FutureBuilder(
        future: _urlConverted,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _sources.isNotEmpty
                ? PageView(
                physics: _pageViewScrollPhysics,
                controller: _pageController,
                scrollDirection: Axis.vertical,
                pageSnapping: true,
                onPageChanged: (index) {
                  setState(() {
                    _scrollOn();
                  });
                },
                children: []..addAll(_sources.map((_source) {
                  return YoutubePlayerScreen(
                      source: _source, pageController: _pageController);
                })))
                : Stack(children: [
              Positioned(
                  top: MediaQuery.of(context).size.height * .05,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                          child: Text("JUST MUSIC",
                              style: TextStyle(
                                  foreground: Paint()
                                    ..shader = linearGradient,
                                  fontFamily: "NotoSans",
                                  fontSize: 20))))),
              Center(
                  child: Text(
                      "Unknown Error:\n Please choose genre(s) and try again !",
                      style: TextStyle(color: Colors.white)))
            ]);
//      return SingleChildScrollView(child: Text(_currentUrl, style: TextStyle(color: Colors.white)));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
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
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return
    _pageBuilder();
  }
}
