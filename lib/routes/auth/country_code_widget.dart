import 'package:flutter/material.dart';
import '../../models/country.dart';
import '../../global_components/empty_app_bar.dart';

class CountryCodeWidget extends StatefulWidget {
  CountryCodeWidget({@required selectedCountry});
  Country selectedCountry;
  WidgetBuilder emptySearchBuilder;

  @override
  _CountryCodeWidgetState createState() => _CountryCodeWidgetState();
}

class _CountryCodeWidgetState extends State<CountryCodeWidget> {
  List<Country> allCountries = Country.ALL;
  List<Country> filteredCountries = [];

  void initState(){
    filteredCountries.addAll(allCountries);
  }

  void _filterCountries(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredCountries = allCountries
          .where((e) =>
              e.isoCode.contains(s) ||
              e.dialingCode.contains(s) ||
              e.name.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(Country e) {
    Navigator.pop(context, e);
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    return Center(child: Container(padding: EdgeInsets.only(top: 20.0), child: Text('No Country Found', style: TextStyle(color: Colors.white))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(43, 47, 57, 1.0),
        appBar: EmptyAppBar(),
        body: Container(
            child: Column(children: <Widget>[
          Row(children: <Widget>[
            Container(
                padding: EdgeInsets.all(3.0),
                child: IconButton(
                    iconSize: 27.0,
                    icon: Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    })),
            Text("Please select country or region.",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold))
          ]),
          Container(
              padding: EdgeInsets.fromLTRB(23.0, 10.0, 23.0, 10.0),
              child: Row(
    children: <Widget> [
      Expanded(child: TextField(
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: "Search for country",
                  contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(145, 145, 155, 1.0),
                            width: 1.5)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(185, 185, 195, 1.0),
                            width: 1.5)),
                    filled: true,
                    fillColor: Color.fromRGBO(75, 75, 85, 1.0)),
                 onChanged: _filterCountries,
              ))])),
                Flexible(child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: ListView(children: []
                        ..addAll(filteredCountries.isEmpty ?
                        [_buildEmptySearchWidget(context)] : filteredCountries.map((country){
                          return ListTile(
                              title: Text(country.name,
                              style: TextStyle(color: Colors.white)),
                              trailing: Text("+${country.dialingCode}",
                                  style: TextStyle(color: Colors.white)),
                          onTap: (){ _selectItem(country);}
                          );
                        })))
              ))])
        ));
  }
}
