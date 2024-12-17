import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'login_page.dart'; // Page de connexion

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {}; // Liste des marqueurs

  // Position de départ de la carte
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(48.8566, 2.3522), // Coordonnées de Paris
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte des Événements"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        onLongPress: (LatLng position) {
          if (FirebaseAuth.instance.currentUser != null) {
            // Ajouter un marqueur si l'utilisateur est connecté
            setState(() {
              _markers.add(
                Marker(
                  markerId: MarkerId(position.toString()),
                  position: position,
                  infoWindow: InfoWindow(title: 'Événement'),
                ),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Vous devez être connecté pour ajouter un marqueur")),
            );
          }
        },
        markers: _markers,
      ),
    );
  }
}
