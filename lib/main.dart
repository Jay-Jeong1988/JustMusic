import 'package:flutter/material.dart';
import './routes/home/home_page.dart';
import './models/user.dart';
import './routes/profile/profile_page.dart';
import './global_components/navbar.dart';
import './global_components/modal_bottom_sheet.dart';
import './routes/auth/country_code_widget.dart';
import './models/country.dart';
import './utils/locationUtil.dart';

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
  Future<Country> countryFuture;
  Country userCountry;
  List<Widget> navTabs;
  int _clicked = 0;

  void initState() {
    countryFuture = getCountryInstance();
    countryFuture.then((country) {
      userCountry = country;
    });
    print("current user: ${widget.user}");
    this.navTabs = [
      HomePage(
        key: PageStorageKey('Page1'),
      ),
      Center(child: Text("?", style: TextStyle(color: Colors.white))),
      Center(child: Text("?", style: TextStyle(color: Colors.white))),
      Center(child: Text("?", style: TextStyle(color: Colors.white))),
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
              setModalBottomSheet(context, userCountry);
            }
          } else
            setState(() {
              _clicked = index;
            });
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: countryFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                body: Stack(
                    children: [
                      navTabs[_clicked],
                      NavBar(navButton)
                    ]));
          }else if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
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
                ]));}});

  }
}
