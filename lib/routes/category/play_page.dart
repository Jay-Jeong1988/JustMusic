import 'dart:convert';

import 'package:JustMusic/global_components/app_ads.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/routes/home/home_page.dart';
import 'package:JustMusic/utils/slide_right_route.dart';
import 'package:firebase_admob/firebase_admob.dart';
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
    _showAd();
  }

  void _showAd() async {
    await Future.delayed(const Duration(milliseconds: 500));
    AppAds.init(bannerUnitId: 'ca-app-pub-7258776822668372/6576702822');
    AppAds.showBanner();
    _singleton.adSize = "full";
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
          left: MediaQuery.of(context).size.width * .5 - MediaQuery.of(context).size.width * 0.15,
            top: MediaQuery.of(context).size.height * .5 - MediaQuery.of(context).size.width * 0.15,
            child: Container(
          width: MediaQuery.of(context).size.width * .3,
          height: MediaQuery.of(context).size.width * .3,
          decoration: BoxDecoration(
            gradient:
            LinearGradient(colors: [
              Color.fromRGBO(244,134,137,1),
              Color.fromRGBO(200,84,107,1),
              Color.fromRGBO(175,36,78,1),
            ],
              begin: Alignment.topLeft,
            ),
            shape: BoxShape.circle,
            color: Colors.white
          ),
          child: IconButton(
            icon: Icon(Icons.play_circle_filled, color: Colors.white),
            iconSize: 80,
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
              AppAds.hideBanner();
            },
          )
        )),
          Positioned(
            top: MediaQuery.of(context).size.height * .1,
              right: MediaQuery.of(context).size.width * .1,
            child: Container(
              width: 50,
              height: 50,
              child: IconButton(
                iconSize: 30,
                  icon: Icon(Icons.grid_on,
                      color: Colors.white),
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