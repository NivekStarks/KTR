import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Marker> markers = [];

    // Récupérer les documents de la collection "markers"
    QuerySnapshot snapshot = await firestore.collection('markers').get();

    // Convertir chaque document en un Marker
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double lat = data['latitude'];
      double lng = data['longitude'];
      String name = data['name'];
      String category = data['category'];
      String address = data['address'];
      String date = data['date'] ?? '';

      // Ajouter un marqueur à la liste
      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _showPopup(context, name, category, address, date),
            child: Column(
              children: [
                Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ],
            ),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;  // Mettre à jour la liste des marqueurs
    });
  }

  // Afficher la popup avec les détails du marqueur
  void _showPopup(BuildContext context, String name, String category, String address, String date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Catégorie: $category"),
            Text("Adresse: $address"),
            if (date.isNotEmpty) Text("Date: $date"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Application EventDeaf', style: TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings), // Icône du bouton
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FibresPage()),
              );
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(48.8566, 2.3522), // Paris
          initialZoom: 5.0,
          maxZoom: 18.0,
          minZoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _markers),  // Affichage des marqueurs sur la carte
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
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
class FibresPage extends StatefulWidget {
  @override
  _FibresPageState createState() => _FibresPageState();
}

class _FibresPageState extends State<FibresPage> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fibres Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choisissez une option :', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ListTile(
              title: Text('Entreprise'),
              leading: Radio(
                value: 'Entreprise',
                groupValue: null,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: Text('Sport'),
              leading: Radio(
                value: 'Sport',
                groupValue: null,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: Text('Association'),
              leading: Radio(
                value: 'Association',
                groupValue: null,
                onChanged: (value) {},
              ),
            ),
            SizedBox(height: 20),
            Text('Sélectionnez une période :', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Début :'),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        startDate = date;
                      });
                    }
                  },
                  child: Text(startDate == null
                      ? 'Choisir'
                      : '${startDate!.toLocal()}'.split(' ')[0]),
                ),
              ],
            ),
            Row(
              children: [
                Text('Fin :'),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        endDate = date;
                      });
                    }
                  },
                  child: Text(endDate == null
                      ? 'Choisir'
                      : '${endDate!.toLocal()}'.split(' ')[0]),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Logic for "Valider"
                  },
                  child: Text('Valider'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                    });
                  },
                  child: Text('Tout Effacer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
}

