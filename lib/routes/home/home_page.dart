import 'dart:convert';

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
  List<String> _sourcePaths = [];
  String _currentUrl = "";
  String _unavailableVideoUrl = "https://www.youtube.com/watch?v=luPm3Dnouvc";
  Future<List<dynamic>> _urlConverted;
  List<dynamic> _musics = [];
  int _previousPageIndex = 0;
  List<String> _categoryTitles = [];

  @override
  void initState() {
    if(widget.selectedCategories != null) {
      _categoryTitles.addAll(widget.selectedCategories.map((category) {
        return category.title;
      }));
    }
      _urlConverted = getMusicsRequest(_categoryTitles);
      _urlConverted.then((musics){
        _musics = musics;
        _musics.forEach((music){
          _sourcePaths.add(music["videoUrl"]);
        });
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
            children: []..addAll(_sourcePaths.map((_sourcePath){
              return YoutubePlayerScreen(_sourcePath, _pageController);
            }))
            );
      });
  }

  Future<List<dynamic>> getMusicsRequest(categories) async {
    var response;
    Map<String, String> queryParameters = {};
    int index = 0;
    categories.forEach((category){
      queryParameters["category${index++}"] = category;
    });
    var uri = queryParameters.isNotEmpty ?
    Uri.http("10.0.2.2:3000", "/music/all", queryParameters) :
        Uri.http("10.0.2.2:3000", "/music/all");
    try {
      response = await http.get(uri);
    } catch (e) {
      print(e);
    }
    List<dynamic> decodedResponse = jsonDecode(response.body);
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print("Decoded response: $decodedResponse");
      return decodedResponse;
    } else {
      throw Exception('Failed to load music data');
    }
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
            return _sourcePaths.isNotEmpty
                ? pageView
                : Center(
                    child: Text("No video source",
                        style: TextStyle(color: Colors.white)));
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
