import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'; // ✅ Location package for real-time tracking
import 'package:geolocator/geolocator.dart'; // ✅ To calculate distance Route connection needed

class SOSMapScreen extends StatefulWidget {
  final Map<String, dynamic> alert;

  SOSMapScreen({required this.alert, required String volunteerId});

  @override
  _SOSMapScreenState createState() => _SOSMapScreenState();
}

class _SOSMapScreenState extends State<SOSMapScreen> {
  late GoogleMapController mapController;
  late LatLng userLocation;
  LatLng? volunteerLocation;
  Location location = Location();
  StreamSubscription<LocationData>? locationSubscription;
  double distanceInMeters = 0.0;

  @override
  void initState() {
    super.initState();
    userLocation = LatLng(widget.alert['latitude'], widget.alert['longitude']);
    _startTrackingVolunteer(); // ✅ Start real-time tracking
  }

  /// ✅ Start tracking the volunteer's real-time location
  void _startTrackingVolunteer() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        volunteerLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _calculateDistance();
      });

      mapController.animateCamera(CameraUpdate.newLatLng(volunteerLocation!));
    });
  }

  /// ✅ Calculate distance between volunteer and victim
  void _calculateDistance() {
    if (volunteerLocation != null) {
      distanceInMeters = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        volunteerLocation!.latitude,
        volunteerLocation!.longitude,
      );
    }
  }

  /// ✅ Mark as Rescued & Stop Tracking
  void _markAsRescued() {
    locationSubscription?.cancel(); // Stop tracking
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rescue Operation Completed!")));
  }

  @override
  void dispose() {
    locationSubscription?.cancel(); // ✅ Stop tracking when leaving screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: MarkerId("user"),
        position: userLocation,
        infoWindow: InfoWindow(title: "User's Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      if (volunteerLocation != null)
        Marker(
          markerId: MarkerId("volunteer"),
          position: volunteerLocation!,
          infoWindow: InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
    };

    Set<Polyline> polylines = {};
    if (volunteerLocation != null) {
      polylines.add(
        Polyline(
          polylineId: PolylineId("volunteer_to_user"),
          points: [volunteerLocation!, userLocation],
          color: Colors.blue,
          width: 5,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("SOS Rescue Map")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: userLocation, zoom: 14),
            markers: markers,
            polylines: polylines,
            onMapCreated: (controller) => mapController = controller,
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text(
                "📏 Distance: ${distanceInMeters.toStringAsFixed(2)} meters",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.check),
        onPressed: _markAsRescued,
      ),
    );
  }
}
