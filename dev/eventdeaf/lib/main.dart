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
        title: Text('Application EventDeaf',
        style: TextStyle(fontSize: 15 ),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(48.8566, 2.3522), // Paris
          initialZoom: 12.0, // Initial zoom level
          maxZoom: 18.0, // Maximum zoom level (closer view)
          minZoom: 5.0, // Minimum zoom level (farther view)
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(48.8566, 2.3522),
                width: 80,
                height: 80,
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Logic to zoom in (if you need programmatic control)
            },
            child: Icon(Icons.zoom_in),
            heroTag: 'zoomIn',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              // Logic to zoom out (if you need programmatic control)
            },
            child: Icon(Icons.zoom_out),
            heroTag: 'zoomOut',
          ),
        ],
      ),
    );
  }
}
