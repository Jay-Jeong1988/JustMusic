import 'dart:async';
import 'dart:convert';
import 'package:JustMusic/utils/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './models/user.dart';
import './routes/category/category_page.dart';
import './global_components/navbar.dart';
import './models/country.dart';
import './utils/locationUtil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'global_components/api.dart';
import 'global_components/singleton.dart';

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
  final Widget navigatedPage;
  AppScreen({Key key, this.navigatedPage})
      : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  Future<Country> countryFuture;
  Country userCountry;
  Widget currentPage;
  FlutterSecureStorage _storage = FlutterSecureStorage();
  Singleton _singleton = Singleton();
  var loadCountryFromDisk;
  bool _loadingCountryFromGPS = false;

  void getSelectedPageFromChild(page) {
    setState(() {
      currentPage = page;
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Api(); //create an Api instance to determine which host the app should use
      _storage.read(key: "user").then((userJson) {
        if (userJson != null) {
          var decodedUserJson = jsonDecode(userJson);
          if (decodedUserJson.isNotEmpty) {
            UserApi.authenticateUser(
                decodedUserJson["contactInfo"]["phoneNumber"])
                .then((isValidUser) {
              if (isValidUser == true) {
                _singleton.user = User.fromJson(jsonDecode(userJson));
                print("I am ${_singleton.user.nickname} (from storage)");
              } else {
                _singleton.user = null;
                _storage.delete(key: "user").catchError((error) {
                  print(error);
                });
              }
            });
          }
        }
      });

    currentPage = widget.navigatedPage ?? CategoryPage();

    loadCountryFromDisk = _loadCountryFromDisk();
    loadCountryFromDisk.then((countryFromDisk){
      if (countryFromDisk != null) {
        userCountry = Country.fromJson(jsonDecode(countryFromDisk));
      }
      else {
        setState((){
          _loadingCountryFromGPS = true;
        });
        countryFuture = getCountryInstance();
        countryFuture.then((country) {
          if (country != null) {
            _setCountryToDisk(Country.toJson(country));
            userCountry = country;
          }
        });
      }
    });
  }

  Future<String> _loadCountryFromDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var country = prefs.getString('country');
    return country;
  }

  Future<void> _setCountryToDisk(country) async {
    SharedPreferences prefs =  await SharedPreferences.getInstance();
    prefs.setString("country", country);
  }

  DateTime currentBackPressTime;

  Future<bool> _onWillPop() async{
    if (_singleton.widgetLayers == 1) {
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
    }else {
      _singleton.widgetLayers-=1;
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadingCountryFromGPS ? countryFuture : loadCountryFromDisk,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return WillPopScope(
                onWillPop: _onWillPop,
                child: Scaffold(
                body: Stack(children: [
              currentPage,
              widget.navigatedPage != null
                  ? NavBar(
                      getSelectedPageFromChild: getSelectedPageFromChild,
                      currentPage: widget.navigatedPage)
                  : NavBar(
                      getSelectedPageFromChild: getSelectedPageFromChild),
            ])));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return
              Center(child:
              Container(
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
            return Center(child: Text("${snapshot.connectionState}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white
            )));
          }
        });
  }
}
