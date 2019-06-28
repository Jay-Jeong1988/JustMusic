import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../global_components/empty_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryPage extends StatefulWidget {

  State<CategoryPage> createState() => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage> {
  Future<List<dynamic>> futureCategories;
  List<Category> _allCategories = [];
  List<Category> _selectedCategories = [];

  @override
  void initState() {
    futureCategories = getCategoriesRequest();
    futureCategories.then((List<dynamic> categories){
      categories.sort((a, b) {
        return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
      });
      setState((){
        _allCategories.addAll(
        categories.map((category){
          return Category.fromJson(category);})
        );
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
            body: _allCategories.isEmpty ?
            EmptySearchWidget(textInput: "No existing category.") :
            Stack(children: [Container(child: CustomScrollView(
                slivers: [
                  SliverGrid(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(childAspectRatio: 0.667,crossAxisCount: 3),
                      delegate: SliverChildListDelegate([]
                        ..addAll(_allCategories.map((category){
                          return GestureDetector(
                              onTap: (){
                                setState((){
                                  _selectedCategories.contains(category) ? _selectedCategories.remove(category) : _selectedCategories.add(category);
                                });
                              },
                              child: Stack(children: [Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(category.imageUrl))),
                              ),
                          _selectedCategories.contains(category) ? Container() : EmptyShadowGrid(),
                                Center(child: Text(category.title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0,color: Colors.white)))]));
                        }))))
                ]
            )
            ),
            EmptyShadowAppBar()]));
      }else if(snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }else if (snapshot.hasError) {
        return Center(
            child: Column(children: <Widget>[
              Text('Error: ${snapshot.error}',
                  style:
                  TextStyle(fontSize: 14.0, color: Colors.white)),
              RaisedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Exit"),
                  textColor: Colors.white,
                  elevation: 7.0,
                  color: Colors.blue)
            ]));
      }else {
        return Center(child: Text("build function returned null", style: TextStyle(color: Colors.white)));
      }

  });}
}