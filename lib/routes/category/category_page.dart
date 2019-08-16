import 'dart:convert';

import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/global_components/singleton.dart';
import 'package:JustMusic/routes/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../global_components/empty_widgets.dart';
import 'dart:math';

class CategoryPage extends StatefulWidget {
  State<CategoryPage> createState() => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  var loadCategoriesFromServer;
  var loadCategoriesFromDisk;
  bool loadingFromServer = false;
  List<dynamic> _allCategories = [];
  List<dynamic> _selectedCategories = [];
  List<Color> gridBgColors = [
    Color.fromRGBO(93, 92, 97, 1),
    Color.fromRGBO(147, 142, 148, 1),
    Color.fromRGBO(84, 122, 149, 1),
    Color.fromRGBO(115, 149, 173, 1),
    Color.fromRGBO(176, 162, 149, 1),
  ];
  Singleton _singleton = Singleton();

  @override
  void initState() {
    super.initState();

    loadCategoriesFromDisk = _loadCategoriesFromDisk();
    loadCategoriesFromDisk.then((categoriesFromDisk) {
      if (categoriesFromDisk == null) {
        setState(() {
          loadingFromServer = true;
        });
        loadCategoriesFromServer = MusicApi.getCategories();
        loadCategoriesFromServer.then((List<dynamic> categoriesFromServer) {
          categoriesFromServer.sort((a, b) {
            return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
          });
          _allCategories.addAll(categoriesFromServer);
          _setCategoriesToDisk(categoriesFromServer);
        });
        print("cateogries loaded from server");
      } else {
        _allCategories.addAll(categoriesFromDisk);
        print("categories loaded from localstorage");
      }
    });
    _loadSelectedCategoriesFromDisk().then((List<dynamic> selectedCategories) {
      setState(() {
        _selectedCategories.addAll(selectedCategories);
      });
    });
  }

  Future<void> _setCategoriesToDisk(List<dynamic> categories) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("categories", json.encode(categories));
  }

  _loadCategoriesFromDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var categories = prefs.getString('categories');
    return categories == null ? null : json.decode(categories);
  }

  Future<void> _setSelectedCategoriesToDisk(List<dynamic> categories) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("selectedCategories", json.encode(categories));
  }

  Future<List<dynamic>> _loadSelectedCategoriesFromDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var categories = prefs.getString('selectedCategories');
    return json.decode(categories);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadingFromServer
            ? loadCategoriesFromServer
            : loadCategoriesFromDisk,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: Color.fromRGBO(20, 20, 25, 1),
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  flexibleSpace: Container(
                      decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color.fromRGBO(27, 30, 40, 1),
                          Color.fromRGBO(35, 42, 51, 1),
                        ]),
                  )),
                  backgroundColor: Colors.transparent,
                  title: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                        Text("Pick genres up to 10",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold)),
                        _selectedCategories.isNotEmpty
                            ? Container(
                                margin: EdgeInsets.fromLTRB(0, 7, 0, 7),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      stops: [
                                        0.4,
                                        0.8,
                                        1
                                      ],
                                      colors: [
                                        Color.fromRGBO(25, 25, 30, 1),
                                        Color.fromRGBO(45, 45, 50, 1),
                                        Color.fromRGBO(85, 85, 90, 1),
                                      ]),
                                  border: Border.all(
                                      color: Colors.white54, width: .7),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0)),
                                ),
                                child: RaisedButton.icon(
                                    elevation: 0,
                                    textColor: Colors.red,
                                    color: Colors.transparent,
                                    onPressed: () {
                                      _setSelectedCategoriesToDisk(
                                          _selectedCategories);
                                      print("ahai$_selectedCategories");
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  AppScreen(
                                                      navigatedPage: HomePage(
                                                          selectedCategories:
                                                              _selectedCategories))));
                                      _singleton.clicked = 0;
                                    },
                                    icon: Icon(Icons.play_circle_outline),
                                    label: Text("PLAY",
                                        style: TextStyle(color: Colors.white))))
                            : Container()
                      ]))),
              body: _allCategories.isEmpty
                  ? EmptySearchWidget(textInput: "No existing category.")
                  : Stack(children: [
                      Container(
                          child: CustomScrollView(slivers: [
                        SliverPadding(
                            padding: EdgeInsets.only(bottom: 50.0),
                            sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: 0.667,
                                        crossAxisCount: 3),
                                delegate: SliverChildListDelegate([]
                                  ..addAll(_allCategories.map((category) {
                                    return GestureDetector(
                                        onTap: () {
                                          if (_selectedCategories.any((e) {
                                            return e['title'] ==
                                                category['title'];
                                          })) {
                                            setState(() {
                                              _selectedCategories.removeWhere(
                                                  (selCat) =>
                                                      selCat['title'] ==
                                                      category['title']);
                                            });
                                          } else {
                                            if (_selectedCategories.length <
                                                10) {
                                              setState(() {
                                                _selectedCategories
                                                    .add(category);
                                              });
                                            }
                                          }
                                        },
                                        child: Stack(children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: gridBgColors[
                                                    Random().nextInt(5)],
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        category['imageUrl']))),
                                          ),
                                          _selectedCategories.any((e) {
                                            return e['title'] ==
                                                category['title'];
                                          })
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color.fromRGBO(
                                                          250, 250, 250, 1.0),
                                                      width: 0.5,
                                                      style: BorderStyle.solid),
                                                ))
                                              : EmptyShadowGrid(),
                                          Center(
                                              child: Text(
                                                  category['title']
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      shadows: [
                                                        Shadow(
                                                            color: Colors.black,
                                                            blurRadius: 3.0)
                                                      ],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0,
                                                      color: _selectedCategories
                                                              .any((e) {
                                                        return e['title'] ==
                                                            category['title'];
                                                      })
                                                          ? Colors.white
                                                          : Color.fromRGBO(255,
                                                              255, 255, 0.6))))
                                        ]));
                                  })))))
                      ])),
                    ]),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Column(children: <Widget>[
              Text('Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 14.0, color: Colors.white)),
              RaisedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Exit"),
                  textColor: Colors.white,
                  elevation: 7.0,
                  color: Colors.blue)
            ]));
          } else {
            return Center(
                child: Text("build function returned null",
                    style: TextStyle(color: Colors.white)));
          }
        });
  }
}
