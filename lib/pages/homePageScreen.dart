import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;
  LatLng _destination = LatLng(-20.434045, 57.674442); // Hardcoded destination

  Set<Polyline> _polylines = {}; // Set to store polylines

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    _location = Location();
    _currentLocation = await _location!.getLocation();
    _cameraPosition = CameraPosition(
      target: LatLng(
        _currentLocation!.latitude ?? 0,
        _currentLocation!.longitude ?? 0,
      ),
      zoom: 15,
    );
    _fetchRoute(); // Fetch the route after getting user's location
  }

  _fetchRoute() async {
    String apiKey = "AIzaSyDXyMwkCa9Y8HnM0qFS3dBCMNdXlaIr8t0";
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_currentLocation?.latitude},${_currentLocation?.longitude}&destination=${_destination.latitude},${_destination.longitude}&key=$apiKey";

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<LatLng> routeCoords =
          _decodePoly(data['routes'][0]['overview_polyline']['points']);
      setState(() {
        _addPolyline(routeCoords); // Add the polyline with route coordinates
      });
    }
  }

  // Method to decode the polyline points into LatLng coordinates
  List<LatLng> _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = <double>[];
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negative then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    var latlngs = <LatLng>[];
    for (var i = 0; i < lList.length; i += 2) {
      latlngs.add(LatLng(lList[i], lList[i + 1]));
    }
    return latlngs;
  }

  // Modified addPolyline method to accept list of LatLng coordinates
  void _addPolyline(List<LatLng> coordinates) {
    _polylines.add(Polyline(
      polylineId: PolylineId('route'),
      points: coordinates,
      color: Colors.blue,
      width: 5,
    ));
  }

  moveToPosition(LatLng latLng) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _getMap();
  }

  Widget _getMarker() {
    return Container(
      width: 40,
      height: 40,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                offset: Offset(0, 3),
                spreadRadius: 4,
                blurRadius: 6)
          ]),
      child: ClipOval(child: Image.asset("assets/profile.png")),
    );
  }

  Widget _getMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _cameraPosition!,
          mapType: MapType.normal,
          polylines: _polylines, // Display polylines on the map
          onMapCreated: (GoogleMapController controller) {
            if (!_googleMapController.isCompleted) {
              _googleMapController.complete(controller);
            }
          },
        ),
        Positioned.fill(
            child: Align(alignment: Alignment.center, child: _getMarker()))
      ],
    );
  }
}
