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
          initialCenter: LatLng(48.8566, 2.3522), // Latitude, Longitude for the initial view
          initialZoom: 13.0, // Initial zoom level
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", // OpenStreetMap tile URL
            subdomains: ['a', 'b', 'c'], 
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(48.8566, 2.3522), // rayan timothée foutent rien depuis l'apm
                width: 80,  
                height: 80, 
                child: Icon(
                  Icons.pin_drop,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
