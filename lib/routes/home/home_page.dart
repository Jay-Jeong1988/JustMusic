import 'package:flutter/material.dart';
import 'package:notpro/routes/home/components/video.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: VideoPlayerScreen()
    );
  }
}

