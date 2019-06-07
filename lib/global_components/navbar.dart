import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  Function navButton;
  NavBar(navButton){
    this.navButton = navButton;
  }
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(0, 1),
        child: BottomAppBar(
            color: Colors.transparent,
            child: Container(
              height: 45.0,
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Color.fromRGBO(190, 190, 190, 0.7),
                          width: 0.2))),
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  widget.navButton(Icons.home, 0),
                  widget.navButton(Icons.device_unknown, 1),
                  widget.navButton(Icons.device_unknown, 2),
                  widget.navButton(Icons.device_unknown, 3),
                  widget.navButton(Icons.person, 4)
                ],
              ),
            )));

  }}