import 'package:flutter/material.dart';
import 'package:JustMusic/routes/home/components/video.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController(
    initialPage: 0
  );
  PageView pageView;
  List<String> _sourcePaths = [];
  Future<String> _urlConverted;

  @override
  void initState() {
    _urlConverted = _fetchVideoURL("https://www.youtube.com/watch?v=wGyUP4AlZ6I");
    _urlConverted.then((url){
      _sourcePaths.add(url);
      pageView = PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index){
            print('changed');
          },
          children: <Widget>[
            VideoPlayerScreen(_sourcePaths[0], _pageController),
        VideoPlayerScreen(_sourcePaths[0], _pageController),
        VideoPlayerScreen(_sourcePaths[0], _pageController),
        VideoPlayerScreen(_sourcePaths[0], _pageController),
        VideoPlayerScreen(_sourcePaths[0], _pageController),
          ]
      );
    });
  }

  Future<String> _fetchVideoURL(String yt) async {
    final response = await http.get(yt);
    Iterable parseAll = _allStringMatches(response.body, RegExp("\"url_encoded_fmt_stream_map\":\"([^\"]*)\""));
    final Iterable<String> parse = _allStringMatches(parseAll.toList()[0], RegExp("url=(.*)"));
    final List<String> urls = parse.toList()[0].split('url=');
    parseAll = _allStringMatches(urls[1], RegExp("([^&,]*)[&,]"));
    String finalUrl = Uri.decodeFull(parseAll.toList()[0]);
    if(finalUrl.indexOf('\\u00') > -1)
      finalUrl = finalUrl.substring(0, finalUrl.indexOf('\\u00'));
    return finalUrl;
  }

  Iterable<String> _allStringMatches(String text, RegExp regExp) => regExp.allMatches(text).map((m) => m.group(0));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _urlConverted,
        builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return _sourcePaths.isNotEmpty ? pageView : Center(child: Text("No video source", style: TextStyle(color: Colors.white)));
      }else if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else {
        return Center(
            child: Column(children: <Widget>[
              Text('Error: ${snapshot.error}',
                  style:
                  TextStyle(fontSize: 14.0, color: Colors.white)),
              RaisedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Exit"),
                  textColor: Colors.white,
                  elevation: 7.0,
                  color: Colors.blue)
            ]));
      }});
    }
}

