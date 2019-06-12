import 'package:flutter/material.dart';

class CountryCodeWidget extends StatefulWidget {

  @override
  _CountryCodeWidgetState createState() => _CountryCodeWidgetState();
}

class _CountryCodeWidgetState extends State<CountryCodeWidget> {
  var _selectedCountryCode;

  void initState(){
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: Text("Country Code Widget",
          style: TextStyle(color: Colors.white),
      ),
    ));
  }
}
