// lib/screens/earthquake_map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EarthquakeMapScreen extends StatefulWidget {
  @override
  _EarthquakeMapScreenState createState() => _EarthquakeMapScreenState();
}

class _EarthquakeMapScreenState extends State<EarthquakeMapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(28.3949, 84.1240); // Nepal center
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    fetchEarthquakeAlerts();
  }

  Future<void> fetchEarthquakeAlerts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/alerts/earthquakes'));
      if (response.statusCode == 200) {
        final List alerts = json.decode(response.body);
        Set<Marker> loadedMarkers = alerts.map((alert) {
          return Marker(
            markerId: MarkerId(alert['_id']),
            position: LatLng(alert['latitude'], alert['longitude']),
            infoWindow: InfoWindow(
              title: 'Mag ${alert['description'].split(" ")[1]}',
              snippet: alert['location'],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
        }).toSet();

        setState(() {
          _markers = loadedMarkers;
        });
      } else {
        print("Failed to load alerts");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Earthquake Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 6,
        ),
        markers: _markers,
      ),
    );
  }
}
