import 'dart:convert';

import 'package:JustMusic/global_components/api.dart';
import 'package:JustMusic/utils/logo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    RemoteUpdateApi.checkUpdates().then((data){
        getPrefInstance().then((pref){
          prefs = pref;
          if (data["isChange"]) {
            setState(() {
              loadingFromServer = true;
            });
            loadCategoriesFromServer = MusicApi.getCategories();
            loadCategoriesFromServer.then((
                List<dynamic> categoriesFromServer) {
              categoriesFromServer.sort((a, b) {
                return a['title'].toLowerCase().compareTo(
                    b['title'].toLowerCase());
              });
              _allCategories.addAll(categoriesFromServer);
              _setCategoriesToDisk(categoriesFromServer);
            });
            print("cateogries loaded from server");
            _loadSelectedCategoriesFromDisk().then((selectedCategories) {
              if (selectedCategories != null)
                setState(() {
                  _selectedCategories.addAll(selectedCategories);
                });
              else
                setState(() {
                  _selectedCategories = [];
                });
            });
          }else {
            loadCategoriesFromDisk = _loadCategoriesFromDisk();
            loadCategoriesFromDisk.then((categoriesFromDisk) {
              if (categoriesFromDisk == null) {
                setState(() {
                  loadingFromServer = true;
                });
                loadCategoriesFromServer = MusicApi.getCategories();
                loadCategoriesFromServer.then((
                    List<dynamic> categoriesFromServer) {
                  categoriesFromServer.sort((a, b) {
                    return a['title'].toLowerCase().compareTo(
                        b['title'].toLowerCase());
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

            _loadSelectedCategoriesFromDisk().then((selectedCategories) {
              if (selectedCategories != null)
                setState(() {
                  _selectedCategories.addAll(selectedCategories);
                });
              else
                setState(() {
                  _selectedCategories = [];
                });
            });
          }
        });
    });
  }

  Future<SharedPreferences> getPrefInstance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<void> _setCategoriesToDisk(List<dynamic> categories) async {
    prefs.setString("categories", json.encode(categories));
  }

  _loadCategoriesFromDisk() async {
    var categories = prefs.getString('categories');
    return categories == null ? null : json.decode(categories);
  }

  Future<void> _setSelectedCategoriesToDisk(List<dynamic> categories) async {
    prefs.setString("selectedCategories", json.encode(categories));
  }

  _loadSelectedCategoriesFromDisk() async {
    var categories = prefs.getString('selectedCategories');
    if (categories != null) return json.decode(categories);
  }

  Widget _customBackButton(){
//    _setSelectedCategoriesToDisk(
//        _selectedCategories);
    return IconButton(icon: Icon(Icons.arrow_back_ios), color: Colors.white,
        onPressed: ()=>Navigator.pop(context, _selectedCategories));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadingFromServer
            ? loadCategoriesFromServer
            : loadCategoriesFromDisk,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return WillPopScope(
                onWillPop: ()async{
                  _setSelectedCategoriesToDisk(_selectedCategories);
                  Navigator.pop(context, _selectedCategories);
                  return Future.value(false);
                }, child: Scaffold(
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
                            _customBackButton(),
                        Text("Pick genres up to 10",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold)),
                      ]))),
              body: _allCategories.isEmpty
                  ? EmptySearchWidget(textInput: "No existing category.")
                  : Stack(children: [
                      Container(
                          child: Column(children: [
                        GestureDetector(
                            onTap: () {
                              if (_selectedCategories.isNotEmpty) {
                                setState(() {
                                  _selectedCategories.clear();
                                });
                              }
                            },
                            child:
                                Stack(alignment: Alignment.center, children: [
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.width * .3,
                                  decoration: BoxDecoration(
                                      color: gridBgColors[Random().nextInt(5)],
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              "http://ik.imagekit.io/kitkitkitit/tr:q-100,ar-10-3,w-1000/all.jpg")))),
                              _selectedCategories.isEmpty
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              .3,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromRGBO(255, 255, 255, 0.1),
                                          )
                                        ],
                                        border: Border.all(
                                            color: Color.fromRGBO(
                                                255, 255, 255, 1.0),
                                            width: 0.5,
                                            style: BorderStyle.solid),
                                      ))
                                  : EmptyShadowGrid(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              .3),
                              Center(
                                  child: Text("A L L",
                                      style: TextStyle(
                                          shadows: [
                                            Shadow(
                                                color: Colors.black,
                                                blurRadius: 3.0)
                                          ],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19.0,
                                          color: _selectedCategories.isEmpty
                                              ? Colors.white
                                              : Color.fromRGBO(
                                                  255, 255, 255, 0.6))))
                            ])),
                        Container(
                            height: MediaQuery.of(context).size.height * .86 -
                                (MediaQuery.of(context).size.width * .3),
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
                                                if (_selectedCategories
                                                    .any((e) {
                                                  return e['title'] ==
                                                      category['title'];
                                                })) {
                                                  setState(() {
                                                    _selectedCategories
                                                        .removeWhere((selCat) =>
                                                            selCat['title'] ==
                                                            category['title']);
                                                  });
                                                } else {
                                                  if (_selectedCategories
                                                          .length <
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
                                                              category[
                                                                  'imageUrl']))),
                                                ),
                                                _selectedCategories.any((e) {
                                                  return e['title'] ==
                                                      category['title'];
                                                })
                                                    ? Container(
                                                        decoration:
                                                            BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Color.fromRGBO(
                                                                    250,
                                                                    250,
                                                                    250,
                                                                    1.0),
                                                            width: 0.5,
                                                            style: BorderStyle
                                                                .solid),
                                                      ))
                                                    : EmptyShadowGrid(),
                                                Center(
                                                    child: Text(
                                                        category['title']
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            shadows: [
                                                              Shadow(
                                                                  color: Colors
                                                                      .black,
                                                                  blurRadius:
                                                                      3.0)
                                                            ],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.0,
                                                            color: _selectedCategories
                                                                    .any((e) {
                                                              return e[
                                                                      'title'] ==
                                                                  category[
                                                                      'title'];
                                                            })
                                                                ? Colors.white
                                                                : Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        0.6))))
                                              ]));
                                        })))))
                            ]))
                      ])),
                    ]),
            ));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child:
            Container(
                child: Logo()
            ));
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
                child: CircularProgressIndicator());
          }
        });
  }
}
