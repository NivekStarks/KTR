import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  // Méthode pour sauvegarder les localisations dans Firestore
  Future<void> saveLocation(double latitude, double longitude) async {
    try {
      await FirebaseFirestore.instance.collection('locations').add({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Localisation sauvegardée dans Firebase');
    } catch (e) {
      print('Erreur lors de la sauvegarde : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Application EventDeaf',
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(48.8566, 2.3522), // Paris
          initialZoom: 12.0, // Niveau de zoom initial
          maxZoom: 18.0, // Zoom maximal
          minZoom: 5.0, // Zoom minimal
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
              // Logiciel pour zoomer (si nécessaire)
            },
            child: Icon(Icons.zoom_in),
            heroTag: 'zoomIn',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              // Logiciel pour dézoomer (si nécessaire)
            },
            child: Icon(Icons.zoom_out),
            heroTag: 'zoomOut',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              // Sauvegarder les coordonnées actuelles (exemple avec Paris)
              saveLocation(48.8566, 2.3522);
            },
            child: Icon(Icons.save),
            heroTag: 'saveLocation',
          ),
        ],
      ),
    );
  }
}
