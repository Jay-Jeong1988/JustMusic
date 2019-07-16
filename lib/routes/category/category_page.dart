import 'package:JustMusic/routes/home/home_page.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/category.dart';
import '../../global_components/empty_widgets.dart';
import 'dart:math';

class CategoryPage extends StatefulWidget {
  State<CategoryPage> createState() => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage> {
  Future<List<dynamic>> futureCategories;
  List<Category> _allCategories = [];
  List<Category> _selectedCategories = [];
  List<Color> gridBgColors = [
    Color.fromRGBO(93, 92, 97, 1),
    Color.fromRGBO(147, 142, 148, 1),
    Color.fromRGBO(84, 122, 149, 1),
    Color.fromRGBO(115, 149, 173, 1),
    Color.fromRGBO(176, 162, 149, 1),
  ];

  @override
  void initState() {
    futureCategories = Category.getCategoriesRequest();
    futureCategories.then((List<dynamic> categories) {
      categories.sort((a, b) {
        return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
      });
      setState(() {
        _allCategories.addAll(categories.map((category) {
          return Category.fromJson(category);
        }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureCategories,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
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
                                          setState(() {
                                            _selectedCategories
                                                    .contains(category)
                                                ? _selectedCategories
                                                    .remove(category)
                                                : _selectedCategories
                                                    .add(category);
                                          });
                                        },
                                        child: Stack(children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: gridBgColors[
                                                    Random().nextInt(5)],
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        category.imageUrl))),
                                          ),
                                          _selectedCategories.contains(category)
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
                                                  category.title.toUpperCase(),
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
                                                              .contains(
                                                                  category)
                                                          ? Colors.white
                                                          : Color.fromRGBO(255,
                                                              255, 255, 0.6))))
                                        ]));
                                  })))))
                      ])),
                      Container(
                          padding: EdgeInsets.fromLTRB(20, 23, 20, 0),
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.4),
                              blurRadius: 10.0,
                            )
                          ]),
                          child: Center(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                Text("Choose genres you like",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'NotoSans',
                                        color: Colors.white,
                                        fontSize: 18)),
                                _selectedCategories.isNotEmpty
                                    ? RaisedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      AppScreen(
                                                          navigatedPage: HomePage(
                                                              selectedCategories:
                                                                  _selectedCategories))));
                                        },
                                        child: Text("PLAY"),
                                        textColor: Colors.white,
                                        elevation: 0,
                                        color: Colors.blue)
                                    : Container()
                              ])))
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
