import 'package:flutter/material.dart';
import './routes/home/home_page.dart';
import './global_components/nav_bar.dart';
import './models/user.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
//                HomePage(),
                  NavBar(widget.user != null ? widget.user.nickname : "no user")
              ])
    );
  }
}
