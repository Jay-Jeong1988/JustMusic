import 'package:geolocator/geolocator.dart';
import '../models/country.dart';

Future<Country> getCountryInstance() async {
  Geolocator geolocator = new Geolocator();
  Position currentLocation;
  List<Placemark> placemark;
  String isoCountryCode;
  Country country;
  try {
    currentLocation = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    placemark = await geolocator.placemarkFromPosition(currentLocation);
  } catch (e) {
    print(e);
  }
  if(placemark != null) {
    isoCountryCode = placemark[0].isoCountryCode;
    print("user iso country code: $isoCountryCode");
    country = Country.findByIsoCode(isoCountryCode);
  }else {
    print("Geolocator plugin failed getting placemark");
  }
  return country;
}

