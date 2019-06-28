import 'package:flutter/material.dart';

class  EmptyAppBar  extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  @override
  Size get preferredSize => Size(0.0,0.0);
}

class EmptySearchWidget extends StatelessWidget {
  String textInput;
  EmptySearchWidget({this.textInput});

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(padding: EdgeInsets.only(top: 20.0), child: Text(textInput, style: TextStyle(color: Colors.white))));
  }
}