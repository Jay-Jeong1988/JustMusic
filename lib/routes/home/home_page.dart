import 'dart:convert';
import 'dart:math';

import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/models/category.dart';
import 'package:JustMusic/routes/home/components/youtube_player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  List<Category> selectedCategories;
  HomePage({Key key, this.selectedCategories}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController(initialPage: 0);
  PageView pageView;
  List<dynamic> _sources = [];
  Future<List<dynamic>> _urlConverted;
  int _previousPageIndex = 0;
  List<String> _categoryTitles = [];

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.white54, Colors.white],
  ).createShader(Rect.fromLTWH(80.0, 0.0, 200, 70.0));

  @override
  void initState() {
    if(widget.selectedCategories != null) {
      _categoryTitles.addAll(widget.selectedCategories.map((category) {
        return category.title;
      }));
    }

      _urlConverted = MusicApi.getMusics(_categoryTitles);
      _urlConverted.then((musics){
        _sources = shuffle(musics);
        pageView = PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              if (index > _previousPageIndex) {
                print('page switched to $index (down)');
                if(index%10 == 0) {
                }
              }
              else print('page switched to $index (up)');
              _previousPageIndex = index;
            },
            children: []..addAll(_sources.map((_source){
              return YoutubePlayerScreen(_source, _pageController);
            }))
            );
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

//  --------------------------------------------Unused Function----------------
//  Future<String> _fixedFetchVideoURL(String yt) async {
//    try {
//      final response = await http.get(yt);
//      Iterable parseAll = _allStringMatches(
//          response.body, RegExp("\"url_encoded_fmt_stream_map\":\"([^\"]*)\""));
//      final Iterable<String> parse =
//          _allStringMatches(parseAll.toList()[0], RegExp("url=(.*)"));
//      final List<String> urls = parse.toList()[0].split('url=');
//      String finalUrl = Uri.decodeFull(urls[1].replaceAll(" ", "%20"));
//      if (finalUrl.indexOf('\\u00') > -1)
//        finalUrl = finalUrl.substring(0, finalUrl.indexOf('\\u00'));
//      return finalUrl;
//    } catch (e) {
//      print(e);
//    }
//  }

//  Iterable<String> _allStringMatches(String text, RegExp regExp) =>
//      regExp.allMatches(text).map((m) => m.group(0));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _urlConverted,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _sources.isNotEmpty
                ? pageView
                : Stack(children: [
              Positioned(
                  top: MediaQuery.of(context).size.height * .05,
//            left: MediaQuery.of(context).size.width * .82,
                  child: Container(width: MediaQuery.of(context).size.width ,
                      child: Center(
                          child: Text("JUST MUSIC",
                              style: TextStyle(foreground: Paint()..shader = linearGradient, fontFamily: "NotoSans", fontSize: 20)))
                  ))
                  ,Center(
                    child: Text("Unknown Error:\n Please choose genre(s) and try again !",
                        style: TextStyle(color: Colors.white)))]);
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
}
