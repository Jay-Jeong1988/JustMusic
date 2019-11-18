import 'dart:convert';

import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/app_ads.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/routes/category/tobeplayed_page.dart';
import 'package:JustMusic/routes/home/home_page.dart';
import 'package:JustMusic/utils/slide_right_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import 'category_page.dart';

class PlayPage extends StatefulWidget {
  createState() => PlayPageState();
}

class PlayPageState extends State<PlayPage> {
  Singleton _singleton = Singleton();
  List<dynamic> _selectedCategories = [];

  @override
  void initState(){
    _loadSelectedCategoriesFromDisk().then((selectedCategories) {
      if (selectedCategories != null) setState(() {
        _selectedCategories.addAll(selectedCategories);
      });
    });
    if (!_singleton.isAdLoaded) AppAds.init(bannerUnitId: 'ca-app-pub-7258776822668372/6576702822');
    if (_singleton.isAdLoaded && !_singleton.isAdShowing) AppAds.showBanner();
  }


  _loadSelectedCategoriesFromDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var categories = prefs.getString('selectedCategories');
    if (categories != null) return json.decode(categories);
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(context) {
    return Stack(children: [Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient:
            LinearGradient(
                colors: [
                  Color.fromRGBO(20, 23, 41, 1),
                  Color.fromRGBO(50, 47, 61, 1),
                  Color.fromRGBO(50, 67, 81, 1),
                  Color.fromRGBO(50, 87, 101, 1),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                tileMode: TileMode.clamp)
        ),
        child: Scaffold(
      body: Stack(
        children: [Positioned(
          left: MediaQuery.of(context).size.width * 0.25 - MediaQuery.of(context).size.width * 0.1,
            top: MediaQuery.of(context).size.height * .5 - MediaQuery.of(context).size.width * 0.1,
            child: Container(
                child: RaisedButton.icon(
                  color: Colors.transparent,
    elevation: 0,
    label: Text("RANDOM PLAY", style: TextStyle(color: Colors.white, fontSize: 22)),
            icon: Icon(Icons.play_circle_filled, color: Colors.white, size: 60,),
            onPressed: (){
              Navigator.push(
                  context,
                  SlideRightRoute(
                      rightToLeft: true,
                      page:
                      AppScreen(navigatedPage:
                          HomePage(
                              selectedCategories:
                              _selectedCategories))));
              _singleton.widgetLayers+=1;
              _singleton.removeNavbar = true;
            },
          )
        )),
          Positioned(
            top: MediaQuery.of(context).size.height * .3 - MediaQuery.of(context).size.width * 0.1,
              left: MediaQuery.of(context).size.width * .25 - MediaQuery.of(context).size.width * 0.1,
            child:
            Container(
              child: RaisedButton.icon(
    color: Colors.transparent,
    elevation: 0,
    label: Text("GENRES", style: TextStyle(color: Colors.white, fontSize: 22)),
                  icon: Icon(Icons.grid_on,
                      color: Colors.white, size: 55),
                  onPressed: () async{
                      var result = await Navigator.push(
                          context,
                          SlideRightRoute(
                              rightToLeft: false,
                              page: CategoryPage()
                          )
                    );
                      if(result != null) {
                        setState(() {
                          _selectedCategories = result;
                        });
                      }
                  })
            )
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.7 - MediaQuery.of(context).size.width * 0.1,
              left: MediaQuery.of(context).size.width * .25 - MediaQuery.of(context).size.width * 0.1,
              child:
              Container(
                  child: RaisedButton.icon(
                      color: Colors.transparent,
                      elevation: 0,
                      label: Text("PLAYLIST", style: TextStyle(color: Colors.white, fontSize: 22)),
                      icon: Icon(Icons.view_list,
                          color: Colors.white, size: 60),
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlideRightRoute(
                                rightToLeft: true,
                                page: ToBePlayedPage(selectedCategories: _selectedCategories)
                            )
                        );
                      })
              )
          )
        ]
        )
    )),
      _singleton.tutorialStatus["playPage"] ? Positioned.fill(child: PlayPageTutorialScreen()) : Container()
    ]);
  }
}

class PlayPageTutorialScreen extends StatefulWidget {
  createState() => PlayPageTutorialScreenState();
}

class PlayPageTutorialScreenState extends State<PlayPageTutorialScreen> {
  Singleton _singleton = Singleton();
  bool _isFinished = false;

  Future<void> _saveTutorialStatusToDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("tutorialStatus", jsonEncode(_singleton.tutorialStatus));
  }

  @override
  Widget build(BuildContext context) {
    return _isFinished ? Container() : GestureDetector(
      onTap: (){
        _singleton.tutorialStatus["playPage"] = false;
        _saveTutorialStatusToDisk().then((v){
          setState(() {
            _isFinished = true;
          });
        });
      },
        child: Container(
    width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
    color: Colors.black45
    ),
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        Positioned(
          top: MediaQuery.of(context).size.height * .1 + 13,
          left: MediaQuery.of(context).size.width * .9 - 250,
          child: Container(
            width: 240,
            height: 55,
            child: Text("1. Select genres first  ->\n and come back .", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "PermanentMarker"))
          )
        ),
        Positioned(
            left: MediaQuery.of(context).size.width * .5 - MediaQuery.of(context).size.width * 0.25,
            top: MediaQuery.of(context).size.height * .5 - MediaQuery.of(context).size.width * 0.25,
            child: Container(
                width: 240,
                height: 30,
                child: Text("2. Play random music ! ", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "PermanentMarker"))
            )
        ),
        Positioned(
            left: MediaQuery.of(context).size.width * .5 - 70,
            top: MediaQuery.of(context).size.height * .75,
            child: Container(
                width: 170,
                height: 30,
                child: Text("Tap to dismiss", style: TextStyle(color: Colors.white70, fontSize: 20, fontFamily: "PermanentMarker"))
            )
        ),
      ])
    )));
  }
}