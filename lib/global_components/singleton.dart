import 'package:JustMusic/models/user.dart';

class Singleton {

  static final Singleton _singleton = new Singleton._privateConstructor();
  bool isFullScreen = false;
  int clicked;
  User user;
  int widgetLayers = 1;
  bool removeNavbar = false;
  Map<String, dynamic> tutorialStatus = {
    "playPage": true,
    "homePage": true,
    "uploadMusicPage": true
  };
  String adSize;

  factory Singleton() {
    return _singleton;
  }

  Singleton._privateConstructor();
}