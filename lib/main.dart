import 'package:flutter/material.dart';
import './models/user.dart';
import './routes/category/category_page.dart';
import './global_components/navbar.dart';
import './models/country.dart';
import './utils/locationUtil.dart';

void main() => runApp(App());

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
  AppScreen({Key key, @required this.user}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with SingleTickerProviderStateMixin {
  Future<Country> countryFuture;
  Country userCountry;
  Widget currentPage;
  Animation<double> _animation;
  AnimationController _animationController;

  void getSelectedPageFromChild(page) {
    setState((){
      currentPage = page;
    });
  }

  void initState() {
    currentPage = CategoryPage();
    countryFuture = getCountryInstance();
    countryFuture.then((country) {
      userCountry = country;
      print("userCountry: ${userCountry}");
    });
    print("current user: ${widget.user}");


    _animationController = AnimationController(
        vsync: this,
        duration: Duration(
            seconds: 2)); //specify the duration for the animation & include `this` for the vsyc
    _animation = Tween<double>(begin: 0, end: 100).animate(
        _animationController); //use Tween animation here, to animate between the values of 1.0 & 2.5.

    _animation.addListener(() {
      //here, a listener that rebuilds our widget tree when animation.value changes
      setState(() {});
      print("dsfd");
    });

    _animation.addStatusListener((status) {
      //AnimationStatus gives the current status of our animation, we want to go back to its previous state after completing its animation
      if (status == AnimationStatus.completed) {
        _animationController
            .reverse(); //reverse the animation back here if its completed
      }
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
                      currentPage,
                      NavBar(widget.user, userCountry, getSelectedPageFromChild),
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
