import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'add_marker_screen.dart';
import 'login_page.dart'; // Page pour ajouter un marqueur

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  // Charger les marqueurs depuis Firestore
  Future<void> _loadMarkers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Marker> markers = [];

    // Récupérer les documents de la collection "markers"
    QuerySnapshot snapshot = await firestore.collection('markers').get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double lat = data['latitude'];
      double lng = data['longitude'];
      String name = data['name'];
      String category = data['category'];
      String address = data['address'];
      String date = data['date'] ?? '';

      // Ajouter un marqueur à la carte
      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _showPopup(context, name, category, address, date),
            child: Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  // Afficher la popup des détails du marqueur
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

  // Ajouter un nouveau marqueur dans Firestore
  void _addMarker() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMarkerScreen()),
    ).then((_) => _loadMarkers()); // Recharger les marqueurs après l'ajout
  }

  // Se déconnecter
  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser; // Vérifier si l'utilisateur est connecté

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte des Marqueurs"),
        actions: [
          if (user != null) // Afficher l'option de déconnexion si l'utilisateur est connecté
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logout,
            ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
         initialCenter: LatLng(48.8566, 2.3522), // Paris
          initialZoom: 5.0,
          maxZoom: 18.0,
          minZoom: 3.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: user != null // Si l'utilisateur est connecté, afficher le bouton pour ajouter un marqueur
          ? FloatingActionButton(
              onPressed: _addMarker, // Ouvre la page pour ajouter un marqueur
              child: const Icon(Icons.add_location),
              tooltip: 'Ajouter un marqueur',
            )
          : null, // Si non connecté, ne pas afficher le bouton
    );
  }
}
