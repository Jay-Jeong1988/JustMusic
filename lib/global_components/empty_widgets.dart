import 'package:flutter/material.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}

class EmptyShadowGrid extends StatelessWidget {
  var height;
  EmptyShadowGrid({this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
        height: height ?? MediaQuery.of(context).size.height,
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
