import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveAlertMapScreen extends StatefulWidget {
  @override
  _LiveAlertMapScreenState createState() => _LiveAlertMapScreenState();
}

class _LiveAlertMapScreenState extends State<LiveAlertMapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final List<String> selectedTypes = ['earthquake', 'flood', 'hospital', 'shelter'];
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _fetchInitialData();
  }

  void _connectSocket() {
    socket = IO.io('http://100.64.199.99:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();
    socket.onConnect((_) => print('Connected to WebSocket'));

    socket.on('new_alert', (data) {
      final alert = data;
      if (selectedTypes.contains(alert['type'])) {
        _addMarker(
          LatLng(alert['location']['lat'], alert['location']['lng']),
          alert['description'],
          alert['type'],
        );
      }
    });
  }

  Future<void> _fetchInitialData() async {
    await _fetchAlerts();
    await _fetchLocations();
  }

  Future<void> _fetchAlerts() async {
    final res = await http.get(Uri.parse('http://100.64.199.99:3000/api/alerts'));
    final List data = json.decode(res.body);
    for (var alert in data) {
      if (selectedTypes.contains(alert['type'])) {
        _addMarker(
          LatLng(alert['location']['lat'], alert['location']['lng']),
          alert['description'],
          alert['type'],
        );
      }
    }
  }

  Future<void> _fetchLocations() async {
    final res = await http.get(Uri.parse('http://192.168.1.9:3000/api/locations'));
    final List data = json.decode(res.body);
    for (var loc in data) {
      if (selectedTypes.contains(loc['type'])) {
        _addMarker(
          LatLng(loc['location']['lat'], loc['location']['lng']),
          loc['name'],
          loc['type'],
        );
      }
    }
  }

  void _addMarker(LatLng position, String title, String type) {
    final markerId = MarkerId('$type-${position.latitude}-${position.longitude}');
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
    switch (type) {
      case 'earthquake':
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        break;
      case 'flood':
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        break;
      case 'hospital':
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        break;
      case 'shelter':
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        break;
    }

    setState(() {
      _markers.add(Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(title: title, snippet: type),
        icon: icon,
      ));
    });
  }

  void _toggleType(String type) {
    setState(() {
      if (selectedTypes.contains(type)) {
        selectedTypes.remove(type);
      } else {
        selectedTypes.add(type);
      }
      _markers.clear();
      _fetchInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Alert Map')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: LatLng(27.7, 85.3),
              zoom: 6,
            ),
            markers: _markers,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Wrap(
              spacing: 8,
              children: ['earthquake', 'flood', 'hospital', 'shelter'].map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: selectedTypes.contains(type),
                  onSelected: (_) => _toggleType(type),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
