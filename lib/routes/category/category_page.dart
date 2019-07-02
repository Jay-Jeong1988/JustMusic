import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../global_components/empty_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    futureCategories = getCategoriesRequest();
    futureCategories.then((List<dynamic> categories) {
      categories.sort((a, b) {
        return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
      });
      setState(() {
        _allCategories.addAll(categories.map((category) {
          return Category.fromJson(category);
        }));
        print(_allCategories);
      });
    });
  }

  Future<List<dynamic>> getCategoriesRequest() async {
    var response;
    var url = 'http://10.0.2.2:3000/music/categories';
    try {
      response = await http.get(url);
    } catch (e) {
      print(e);
    }
    List<dynamic> decodedResponse = jsonDecode(response.body);
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print(decodedResponse);
      return decodedResponse;
    } else {
      throw Exception('Failed to load categories');
    }
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
                  :
                      Stack(children: [
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
                                                    shadows: [Shadow(color: Colors.black, blurRadius: 3.0)],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0,
                                                      color: _selectedCategories
                                                              .contains(
                                                                  category)
                                                          ? Colors.white
                                                          : Color.fromRGBO(255, 255, 255, 0.6))))
                                        ]));
                                  })))))
                      ])),
                      EmptyShadowAppBar(text: "Choose every genre you like")
                    ]),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
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
