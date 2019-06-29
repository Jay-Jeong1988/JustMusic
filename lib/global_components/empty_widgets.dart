import 'package:flutter/material.dart';

class  EmptyAppBar  extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  @override
  Size get preferredSize => Size(0.0,0.0);
}

class  EmptyShadowAppBar  extends StatelessWidget {
  final String text;
  EmptyShadowAppBar({this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
      boxShadow: [BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.4),
      blurRadius: 10.0,
        spreadRadius: 5.0
      )]
    ),child: this.text != null ? Center(child: Text("Choose genres you like",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'NotoSans',
            color: Colors.white, fontSize: 16))) : Container());
  }
}

class  EmptyShadowGrid  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
                color: Color.fromRGBO(30, 30, 30, 0.7),
            )]
        ));
  }
}

class EmptySearchWidget extends StatelessWidget {
  String textInput;
  EmptySearchWidget({this.textInput});

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(padding: EdgeInsets.only(top: 20.0), child: Text(textInput, style: TextStyle(color: Colors.white))));
  }
}