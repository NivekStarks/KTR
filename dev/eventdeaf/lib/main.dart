import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Map Demo'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(51.5, -0.09), // Latitude, Longitude for the initial view
          initialZoom: 13.0, // Initial zoom level
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", // OpenStreetMap tile URL
            subdomains: ['a', 'b', 'c'], // Optional subdomains for OpenStreetMap
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(51.5, -0.09), // Marker coordinates
                width: 80,  // Set the width of the marker
                height: 80, // Set the height of the marker
                child: Icon(
                  Icons.pin_drop,
                  color: Colors.red,
                  size: 40, // Adjust the icon size
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
