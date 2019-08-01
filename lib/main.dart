import 'dart:async';
import 'dart:convert';
import 'package:JustMusic/utils/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './models/user.dart';
import './routes/category/category_page.dart';
import './global_components/navbar.dart';
import './models/country.dart';
import './utils/locationUtil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'global_components/api.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(App());
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JustMusic',
        theme: ThemeData(canvasColor: Colors.transparent),
        home: AppScreen());
  }
}

class AppScreen extends StatefulWidget {
  final User user;
  final Widget navigatedPage;
  AppScreen({Key key, this.user, this.navigatedPage})
      : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  Future<Country> countryFuture;
  Country userCountry;
  Widget currentPage;
  FlutterSecureStorage _storage = FlutterSecureStorage();
  User user;

  void getSelectedPageFromChild(page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  void initState() {
    super.initState();
//    Api(); //create an Api instance to determine which host the app should use
    if (widget.user == null) {
      _storage.read(key: "user").then((userJson) {
        if (userJson != null && jsonDecode(userJson)["user"].isNotEmpty) {
          UserApi.authenticateUser(
                  jsonDecode(userJson)["user"]["contactInfo"]["phoneNumber"])
              .then((isValidUser) {
            if (isValidUser == true) {
              this.user = User.fromJson(jsonDecode(userJson));
              print("I am ${user.nickname} (from storage)");
            } else {
              _storage.delete(key: "user").catchError((error) {
                print(error);
              });
            }
          });
        } else {
          user = null;
        }
      });
    } else {
      user = widget.user;
    }

    currentPage =
        widget.navigatedPage != null ? widget.navigatedPage : CategoryPage();
    countryFuture = getCountryInstance();
    countryFuture.then((country) {
      _storage.write(key: "country", value: Country.toJson(country));
      userCountry = country;
    });
  }

  DateTime currentBackPressTime;

  Future<bool> _onWillPop() async{
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: "Tap agin to exit",
          gravity: ToastGravity.CENTER,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.5)
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: countryFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return WillPopScope(
                onWillPop: _onWillPop,
                child: Scaffold(
                body: Stack(children: [
              currentPage,
              widget.navigatedPage != null
                  ? NavBar(
                      user: user,
                      getSelectedPageFromChild: getSelectedPageFromChild,
                      currentPage: widget.navigatedPage)
                  : NavBar(
                      user: user,
                      getSelectedPageFromChild: getSelectedPageFromChild),
            ])));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return
//              Scaffold(
//                body: Stack(children: [
//              Center(child: CircularProgressIndicator()),
//              NavBar(
//                  user: user,
//                  getSelectedPageFromChild: getSelectedPageFromChild)
//            ]));
              Center(child:
              Container(
//              width: animation.value,
//            height: animation.value,
                  child: Logo()
              ));
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
            return Center();
          }
        });
  }
}
