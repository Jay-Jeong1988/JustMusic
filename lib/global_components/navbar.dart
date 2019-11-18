import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/routes/category/play_page.dart';
import 'package:JustMusic/routes/create/upload_music_page.dart';
import 'package:JustMusic/routes/playLists/play_lists_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../global_components/modal_bottom_sheet.dart';
import '../routes/profile/profile_page.dart';
import 'app_ads.dart';

class NavBar extends StatefulWidget {
  final Function getSelectedPageFromChild;

  NavBar({this.getSelectedPageFromChild});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with WidgetsBindingObserver {
  int _clicked = 0;
  Singleton _singleton = new Singleton();
  List<Widget> navPages = [
    PlayPage(),
    UploadMusicPage(),
    PlayListsPage(),
    ProfilePage(),
  ];
  bool _isInPipMode = false;
  AppLifecycleState _lastLifecycleState;
  static const MethodChannel _channel = const MethodChannel('flutter_android_pip');

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _clicked = _singleton.clicked ?? _clicked;
  }

  Future<void> sendPlayingStatusToNative() async {
    String response = "";
    try {
      final String result = await _channel.invokeMethod('playingStatus', {"isPlaying": false});
      response = result;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    print(response);
  }

  Widget navButton(IconData icon, int index) {
    return RawMaterialButton(
        elevation: 0,
        constraints: BoxConstraints(maxWidth: 40.0, maxHeight: 70.0),
        fillColor: Colors.transparent,
        child: Container(
            height: 50.0,
            decoration: _clicked == index
                ? BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white, width: 3.0)))
                : null,
            child: Icon(icon,
                color: _clicked == index
                    ? Colors.white
                    : Color.fromRGBO(190, 190, 190, 1),
                size: 30.0)),
        onPressed: () {
          sendPlayingStatusToNative();
          if ((index == 1 || index == 2 || index == 3) && _singleton.user == null) {
            setModalBottomSheet(context);
            _singleton.clicked = index;
          } else {
            setState(() {
              _clicked = index;
            });
            widget.getSelectedPageFromChild(navPages[index]);
          }
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lastLifecycleState = state;
    print("Last life cycle state: $_lastLifecycleState");
    if(_lastLifecycleState == AppLifecycleState.inactive) {
      setState(() {
        _isInPipMode = true;
      });
    }else if(_lastLifecycleState == AppLifecycleState.resumed){
      setState(() {
        _isInPipMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
    _singleton.removeNavbar ? Container() :
      _singleton.isFullScreen ? Container() : Positioned(
        bottom: 0.0,
        child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            child: _isInPipMode ? Container() : Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              height: _singleton.isAdShowing ? 110.0 : 50.0,
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  navButton(Icons.play_arrow, 0),
                  navButton(Icons.add_box, 1),
                  navButton(Icons.subscriptions, 2),
                  navButton(Icons.person, 3)
                ],
              ),
            )));
  }
}
