import 'package:flutter/material.dart';
import 'package:notpro/routes/home/components/video.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController(
    initialPage: 1
  );
  PageView pageView;
  String former = "assets/videos/example2.mp4";
  String current = "assets/videos/example3.mp4";
  String latter = "assets/videos/example4.mp4";
  String lattere = "assets/videos/example1.mp4";
  List<String> _sourcePaths;

  @override
  void initState() {
    _sourcePaths = [former, lattere, current, latter];

    pageView = PageView(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index){
        print('changed');
        },
      children: <Widget>[
        VideoPlayerScreen(_sourcePaths[0], _pageController),
        VideoPlayerScreen(_sourcePaths[1], _pageController),
        VideoPlayerScreen(_sourcePaths[2], _pageController),
        VideoPlayerScreen(_sourcePaths[3], _pageController),
      ]
    );
  }


  @override
  Widget build(BuildContext context) {
    return pageView;
  }
}

