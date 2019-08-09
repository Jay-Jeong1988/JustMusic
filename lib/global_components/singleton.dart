import 'package:JustMusic/models/user.dart';

class Singleton {

  static final Singleton _singleton = new Singleton._privateConstructor();
  bool isFullScreen = false;
  int clicked;
  User user;

  factory Singleton() {
    return _singleton;
  }

  Singleton._privateConstructor();
}