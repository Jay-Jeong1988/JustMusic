import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeoListenPage extends StatefulWidget {
  @override
  _GeoListenPageState createState() => _GeoListenPageState();
}

class _GeoListenPageState extends State<GeoListenPage> {
  Geolocator geolocator = Geolocator();
  Position userLocation;
  String country;

  @override
  void initState() {
    super.initState();
    print("geolocation initialized");
//    _getLocation().then((position) {
//      _getPlacemark(position).then((List<Placemark> placemark) {
//        setState((){
//          userLocation = position;
//          country = placemark[0].country;
//        });
//      });
//    });
    _setLocationAndCountry();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[
            userLocation == null
                ? CircularProgressIndicator()
                : Text("Location:" +
                userLocation.latitude.toString() +
                " " +
                userLocation.longitude.toString() + "\n" +
                country.toString(),
            style: TextStyle(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                onPressed: () {
//                  _getLocation().then((value) {
//                    setState(() {
//                      userLocation = value;
//                    });
//                  });
                    _setLocationAndCountry();
                },
                color: Colors.blue,
                child: Text(
                  "Get Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
  }

//  Future<Position> _getLocation() async {
//    var currentLocation;
//    try {
//      currentLocation = await geolocator.getCurrentPosition(
//          desiredAccuracy: LocationAccuracy.best);
//    } catch (e) {
//      currentLocation = null;
//    }
//    return currentLocation;
//  }
//
//  Future<List<Placemark>> _getPlacemark(userLocation) async {
//    List<Placemark> placemark;
//    try {
//      placemark = await geolocator.placemarkFromPosition(userLocation);
//    } catch (e) {
//      placemark = null;
//    }
//    return placemark;
//  }

  void _setLocationAndCountry() async {
    var currentLocation;
    var placemark;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      placemark = await geolocator.placemarkFromPosition(currentLocation);
    } catch (e) {
      print(e);
      currentLocation = null;
    }
    setState((){
      this.userLocation = currentLocation;
      this.country = placemark[0].country;
    });
  }
}