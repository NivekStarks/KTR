import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'database_helper.dart';  // Importer votre fichier de base de données

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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadMarkers();  // Charger les marqueurs depuis la base de données
  }

  // Charger les marqueurs depuis la base de données
 Future<void> _loadMarkers() async {
  try {
    var dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> markerRows = await dbHelper.getAllMarkers();

    List<Marker> loadedMarkers = markerRows.map((row) => 
      Marker(
        point: LatLng(row['latitude'], row['longitude']),
        width: 80,
        height: 80,
        child: Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      )
    ).toList();

    setState(() {
      _markers = loadedMarkers;
    });
  } catch (e) {
    print("Error loading markers: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application EventDeaf', style: TextStyle(fontSize: 15)),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(48.8566, 2.3522), // Paris
          initialZoom: 12.0, // Niveau de zoom initial
          maxZoom: 18.0, // Niveau de zoom maximum
          minZoom: 5.0, // Niveau de zoom minimum
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: _markers, // Affichage des marqueurs récupérés
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Zoom avant
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 0.5,
              );
            },
            child: Icon(Icons.zoom_in),
            heroTag: 'zoomIn',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              // Zoom arrière
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 0.5,
              );
            },
            child: Icon(Icons.zoom_out),
            heroTag: 'zoomOut',
          ),
        ],
      ),
    );
  }
}
