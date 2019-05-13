import 'package:flutter/material.dart';
import './routes/home/home_page.dart';
import './global_components/nav_bar.dart';
import './routes/auth/phone_auth_page.dart';

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
  AppScreen({Key key}) : super(key: key);
  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  String _loggedInUser = "Jay";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
                HomePage(),
                NavBar(_loggedInUser)
              ])
    );
  }
}
