import 'package:flutter/material.dart';
import 'package:notpro/pages/home/components/video.dart';
import './global_components/nav_bar.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NotPro',
        theme: ThemeData(canvasColor: Colors.transparent),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _loggedInUser = "Jay";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
                Container(
                    child: VideoPlayerScreen()
                ),
                NavBar(_loggedInUser)
              ])
    );
  }
}
