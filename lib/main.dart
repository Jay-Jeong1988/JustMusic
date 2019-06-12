import 'package:flutter/material.dart';
import './routes/home/home_page.dart';
import './models/user.dart';
import './routes/profile/profile_page.dart';
import './global_components/navbar.dart';
import './global_components/modal_bottom_sheet.dart';
import './routes/auth/country_code_widget.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NotPro',
        theme: ThemeData(canvasColor: Colors.transparent),
        home: AppScreen());
  }
}

class AppScreen extends StatefulWidget {
  final User user;
  AppScreen({Key key, @required this.user}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  List<Widget> navTabs;
  int _clicked = 0;

  void initState() {
    print("current user: ${widget.user}");
    this.navTabs = [
      HomePage(
        key: PageStorageKey('Page1'),
      ),
      Center(child: Text("?", style: TextStyle(color: Colors.white))),
      Center(child: Text("?", style: TextStyle(color: Colors.white))),
      CountryCodeWidget(),
      ProfilePage(widget.user),
    ];
  }

  Widget navButton(IconData icon, int index) {
    return RawMaterialButton(
        constraints: BoxConstraints(maxWidth: 40.0, maxHeight: 40.0),
        fillColor: Colors.transparent,
        child: Container(
            height: 45.0,
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
          if (index == 4) {
            if (widget.user != null) {
              setState(() {
                _clicked = index;
              });
            } else {
              setModalBottomSheet(context);
            }
          } else
            setState(() {
              _clicked = index;
            });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              navTabs[_clicked],
              NavBar(navButton)
            ]));
  }
}
