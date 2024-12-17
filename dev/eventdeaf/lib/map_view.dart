import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
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
        child: Icon(Icons.location_pin, color: Colors.red, size: 40),
      );
    }).toList();

    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carte des Événements')),
      body: FlutterMap(
        options: MapOptions(initialCenter: LatLng(48.8566, 2.3522), initialZoom: 5.0),
        children: [
          TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
