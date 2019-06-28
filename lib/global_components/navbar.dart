import 'package:flutter/material.dart';
import '../global_components/modal_bottom_sheet.dart';
import '../routes/home/home_page.dart';
import '../routes/profile/profile_page.dart';
import '../routes/category/category_page.dart';

class NavBar extends StatefulWidget {
  var user;
  var userCountry;
  Function setSelectedPageToParent;

  NavBar(user, userCountry, getSelectedPageFromChild){
    this.user = user;
    this.userCountry = userCountry;
    this.setSelectedPageToParent = getSelectedPageFromChild;
  }
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _clicked = 0;
  List<Widget> navPages;

  void initState() {
    this.navPages = [
      HomePage(
        key: PageStorageKey('Page1'),
      ),
      CategoryPage(),
      Center(child: Text(
          "Upload New Music", style: TextStyle(color: Colors.white))),
      Center(child: Text("?", style: TextStyle(color: Colors.white))),
      ProfilePage(widget.user),
    ];
  }

  Widget navButton(IconData icon, int index) {
    return RawMaterialButton(
      elevation: 0,
        constraints: BoxConstraints(maxWidth: 40.0, maxHeight: 70.0),
        fillColor: Colors.transparent,
        child: Container(
            height: 50.0,
            decoration: _clicked == index
                ? BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.white, width: 3.0)))
                : null,
            child: Icon(icon,
                color: _clicked == index
                    ? Colors.white
                    : Color.fromRGBO(190, 190, 190, 1),
                size: 30.0)),
        onPressed: () {
//          _animationController.forward();
          if (index == 4 && widget.user == null) {
              setModalBottomSheet(context, widget.userCountry);
          }else {
            setState(() {
              _clicked = index;
            });
            widget.setSelectedPageToParent(navPages[index]);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(0, 1),
        child: BottomAppBar(
            color: Colors.transparent,
            child: Container(
              height: 50.0,
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(
                  spreadRadius: 5.0,
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  blurRadius: 5.0,
                )],
                  border: Border(
                      top: BorderSide(
                          color: Color.fromRGBO(190, 190, 190, 0.7),
                          width: 0.2))),
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  navButton(Icons.play_arrow, 0),
                  navButton(Icons.grid_on, 1),
                  navButton(Icons.add_box, 2),
                  navButton(Icons.device_unknown, 3),
                  navButton(Icons.person, 4)
                ],
              ),
            )));

  }}