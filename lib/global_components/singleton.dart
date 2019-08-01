class Singleton {

  static final Singleton _singleton = new Singleton._privateConstructor();
  bool isFullScreen = false;
  int clicked;

  factory Singleton() {
    return _singleton;
  }

  Singleton._privateConstructor();
}