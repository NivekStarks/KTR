import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart'; // Pour la gestion des dates
import 'pages/login_page.dart'; // Importer LoginPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase initialization
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
  String? _selectedCategory;
  List<String> _categories = [];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final DateFormat _dateFormat = DateFormat("yyyy-MM-dd HH:mm");

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadMarkers();
  }

  // Récupérer les catégories depuis Firestore
  Future<void> _loadCategories() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('markers').get();
    Set<String> categorySet = {};

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      categorySet.add(data['category']);
    }

    setState(() {
      _categories = categorySet.toList();
    });
  }

  // Charger les marqueurs en fonction des filtres (catégorie et dates)
  Future<void> _loadMarkers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Marker> markers = [];

    QuerySnapshot snapshot = await firestore.collection('markers').get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double lat = data['latitude'];
      double lng = data['longitude'];
      String name = data['name'];
      String category = data['category'];
      String address = data['address'];
      String dateStr = data['date'] ?? '';
      DateTime? date = dateStr.isNotEmpty ? _dateFormat.parse(dateStr) : null;

      // Appliquer le filtre sur la catégorie et les dates
      if ((_selectedCategory == null || _selectedCategory == category) &&
          (_selectedStartDate == null ||
              (date != null && date.isAfter(_selectedStartDate!))) &&
          (_selectedEndDate == null ||
              (date != null && date.isBefore(_selectedEndDate!)))) {
        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () =>
                  _showPopup(context, name, category, address, dateStr),
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  // Afficher la popup avec les détails du marqueur
  void _showPopup(BuildContext context, String name, String category,
      String address, String date) {
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

  // Méthode pour ouvrir le menu des filtres
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Filtres"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sélectionner la catégorie
            DropdownButton<String>(
              hint: Text("Choisir une catégorie"),
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            SizedBox(height: 10),
            // Sélectionner la date de début
            TextButton(
              onPressed: () async {
                DateTime? startDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedStartDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (startDate != null) {
                  setState(() {
                    _selectedStartDate = startDate;
                  });
                }
              },
              child: Text(_selectedStartDate == null
                  ? 'Choisir une date de début'
                  : 'Début: ${_dateFormat.format(_selectedStartDate!)}'),
            ),
            // Sélectionner la date de fin
            TextButton(
              onPressed: () async {
                DateTime? endDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedEndDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (endDate != null) {
                  setState(() {
                    _selectedEndDate = endDate;
                  });
                }
              },
              child: Text(_selectedEndDate == null
                  ? 'Choisir une date de fin'
                  : 'Fin: ${_dateFormat.format(_selectedEndDate!)}'),
            ),
            SizedBox(height: 10),
            // Ajouter un bouton pour réinitialiser les filtres
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _selectedStartDate = null;
                  _selectedEndDate = null;
                });
                _loadMarkers(); // Recharger tous les marqueurs
                Navigator.of(context).pop(); // Fermer le dialogue
              },
              child: Text('Réinitialiser les filtres'),
            ),
          ],
        ),
        actions: [
          // Bouton de validation pour appliquer les filtres et fermer la boîte de dialogue
          TextButton(
            onPressed: () {
              _loadMarkers(); // Appliquer les filtres et recharger les marqueurs
              Navigator.of(context).pop(); // Fermer le dialogue
            },
            child: Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application EventDeaf'),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
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
          MarkerLayer(
              markers: _markers), // Affichage des marqueurs sur la carte
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bouton de filtre
          FloatingActionButton(
            onPressed: _showFilterDialog,
            child: Icon(Icons.filter_alt),
            heroTag: 'filterButton',
          ),
          SizedBox(height: 10),
          // Bouton de zoom +
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
          // Bouton de zoom -
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
