import 'package:JustMusic/models/category.dart';
import 'package:JustMusic/routes/home/home_page.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}

class EmptyShadowAppBar extends StatelessWidget {
  final String text;
  final List<Category> selectedCategories;
  EmptyShadowAppBar({this.text, this.selectedCategories});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 23, 20, 0),
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.4),
            blurRadius: 10.0,
//        spreadRadius: 5.0
          )
        ]),
        child: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text(this.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'NotoSans',
                      color: Colors.white,
                      fontSize: 16)),
              selectedCategories.isNotEmpty
                  ? RaisedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => AppScreen(
                                    navigatedPage: HomePage(
                                        key: PageStorageKey('Page1'),
                                        selectedCategories:
                                            selectedCategories))));
                      },
                      child: Text("PLAY"),
                      textColor: Colors.white,
                      elevation: 0,
                      color: Colors.blue)
                  : Container()
            ])));
  }
}

class EmptyShadowGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(30, 30, 30, 0.8),
          )
        ]));
  }
}

class EmptySearchWidget extends StatelessWidget {
  final String textInput;
  EmptySearchWidget({this.textInput});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(textInput, style: TextStyle(color: Colors.white))));
  }
}
