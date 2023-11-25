import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DustBin {
  final double latitude;
  final double longitude;
  final String address;
  final double distance;

  const DustBin(
      {required this.latitude,
      required this.longitude,
      required this.address,
      required this.distance});

  factory DustBin.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'Latitude': double latitude,
        'Longitude': double longitude,
        'Assessor Address': String address,
        'distance': double distance,
      } =>
        DustBin(
            latitude: latitude,
            longitude: longitude,
            address: address,
            distance: distance),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}

Future<List<DustBin>> fetchBins(Position position) async {
  final response = await http.post(Uri.parse('http://10.10.8.83:3000/locate'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "lat": position.latitude,
        "lon": position.longitude,
        "radius": "10"
      }));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<dynamic> jsonList = jsonDecode(response.body);
    List<DustBin> bins = jsonList
        .map((json) => DustBin.fromJson(json as Map<String, dynamic>))
        .toList();
    // print(jsonList);
    return bins;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}

class _MapPageState extends State<MapPage> {
  LatLng _currentLocation = LatLng(0.0, 0.0);
  double _initialZoom = 9.2;
  MapController _mapController = MapController();
  List<CircleMarker> _circleMarkers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getBins();
  }

  void _updateLocation(Position position) {
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(LatLng(position.latitude, position.longitude), 13.0);
      _circleMarkers = [
        CircleMarker(
          point: LatLng(position.latitude, position.longitude),
          color: Colors.blue.withOpacity(0.7),
          borderColor: Colors.blue,
          borderStrokeWidth: 2,
          useRadiusInMeter: true,
          radius: 100,
        ),
      ];
    });
  }

  void _updateBins(List<DustBin> bins) {
    List<CircleMarker> circleMarkers = _circleMarkers;
    List<Marker> markers = [];
    for (DustBin bin in bins) {
      CircleMarker circleMarker = CircleMarker(
        point: LatLng(bin.latitude, bin.longitude),
        color: Colors.green.withOpacity(0.7),
        borderColor: Colors.red,
        borderStrokeWidth: 2,
        useRadiusInMeter: true,
        radius: 40,
      );
      // Marker now =  Marker( //marker
      //           width: 25.0,
      //           height: 25.0,
      //           point: LatLng(bin.latitude, bin.longitude),
      //           builder: (context) {
      //           return Container(
      //               child: IconButton(
      //                   icon: Icon(Icons.my_location),
      //                   iconSize: 25.0,
      //                   color: Color(0xff9045f7),
      //                   onPressed: () {
      //                       print('marker tapped');
      //                   },
      //                   ),
      //               );
      //           }
      //       )
      circleMarkers.add(circleMarker);
    }

    setState(() {
      _circleMarkers = circleMarkers;
    });
  }

  Future<void> _getBins() async {
    Position position = await _determinePosition();
    List<DustBin> bins = await fetchBins(position);
    _updateBins(bins);
  }

  Future<void> _getCurrentLocation() async {
    Position position = await _determinePosition();
    _updateLocation(position);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentLocation,
        zoom: _initialZoom,
      ),
      mapController: _mapController,
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        // MarkerLayer(markers: markers),
        CircleLayer(circles: _circleMarkers),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }
}
