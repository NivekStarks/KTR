import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_marker_screen.dart';

class MapWithMarkers extends StatefulWidget {
  @override
  _MapWithMarkersState createState() => _MapWithMarkersState();
}

class _MapWithMarkersState extends State<MapWithMarkers> {
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    var snapshot = await FirebaseFirestore.instance.collection('markers').get();
    List<Marker> markers = snapshot.docs.map((doc) {
      var data = doc.data();
      return Marker(
        point: LatLng(data['latitude'], data['longitude']),
        width: 80,
        height: 80,
        child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
      );
    }).toList();

    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Marqueurs')),
      body: FlutterMap(
        options: MapOptions(initialCenter: LatLng(48.8566, 2.3522), initialZoom: 5.0),
        children: [
          TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddMarkerScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
