import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userLocation;
  List<LatLng> volunteerLocations = [
    LatLng(27.7172, 85.3240), // Kathmandu
    LatLng(28.2096, 83.9856), // Pokhara
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled. Please enable them.")),
      );
      return;
    }

    // Check and request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permissions are denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permissions are permanently denied.")),
      );
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  double calculateDistance(LatLng start, LatLng end) {
    final Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Map with Location")),
      body: userLocation == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
  options: MapOptions(
    initialCenter: userLocation ?? LatLng(27.7172, 85.3240), // Default location
    initialZoom: 13.0, // Correct parameter for zoom
    onTap: (tapPosition, latLng) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tapped location: ${latLng.latitude}, ${latLng.longitude}")),
      );
    },
  ),
  children: [
    TileLayer(
      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      userAgentPackageName: 'com.example.app',
    ),
    MarkerLayer(
      markers: [
        if (userLocation != null)
          Marker(
            point: userLocation!,
            width: 50,
            height: 50,
            child: Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
      ],
    ),
  ],
),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userLocation != null) {
            for (var volunteer in volunteerLocations) {
              double distance = calculateDistance(userLocation!, volunteer);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Distance to Volunteer: ${distance.toStringAsFixed(2)} km")),
              );
            }
          }
        },
        child: Icon(Icons.directions),
      ),
    );
  }
}
