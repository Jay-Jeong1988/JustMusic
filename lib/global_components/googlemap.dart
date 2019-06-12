//class GoogleMapsDemo extends StatefulWidget {
//  @override
//  _GoogleMapsDemoState createState() => _GoogleMapsDemoState();
//}
//
//class _GoogleMapsDemoState extends State<GoogleMapsDemo> {
//  GoogleMapController mapController;
//  Location location = Location();
//
//  Marker marker;
//
//  @override
//  void initState() {
//    super.initState();
//    location.onLocationChanged().listen((location) async {
//      if(marker != null) {
//        mapController.removeMarker(marker);
//      }
//      marker = await mapController?.addMarker(MarkerOptions(
//        position: LatLng(location["latitude"], location["longitude"]),
//      ));
//      mapController?.moveCamera(
//        CameraUpdate.newCameraPosition(
//          CameraPosition(
//            target: LatLng(
//              location["latitude"],
//              location["longitude"],
//            ),
//            zoom: 20.0,
//          ),
//        ),
//      );
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Column(
//        children: <Widget>[
//          Container(
//            height: MediaQuery.of(context).size.height,
//            width: MediaQuery.of(context).size.width,
//            child: GoogleMap(
//              onMapCreated: (GoogleMapController controller) {
//                mapController = controller;
//              },
//              options: GoogleMapOptions(
//                cameraPosition: CameraPosition(
//                  target: LatLng(37.4219999, -122.0862462),
//                ),
//                myLocationEnabled: true,
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//}