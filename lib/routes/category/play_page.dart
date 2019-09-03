import 'dart:convert';

import 'package:JustMusic/global_components/singleton.dart';
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
  }

  _loadSelectedCategoriesFromDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var categories = prefs.getString('selectedCategories');
    if (categories != null) return json.decode(categories);
  }

  @override
  Widget build(context) {
    return Container(
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
    ));
  }
}