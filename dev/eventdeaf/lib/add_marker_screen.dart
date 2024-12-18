import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; // Import pour revenir à la carte dans main.dart

class AddMarkerScreen extends StatefulWidget {
  @override
  _AddMarkerScreenState createState() => _AddMarkerScreenState();
}

class _AddMarkerScreenState extends State<AddMarkerScreen> {
  // Clé pour le formulaire
  final _formKey = GlobalKey<FormState>();

  // Variables pour stocker les champs du formulaire
  String address = '';
  String category = '';
  String date = '';
  double latitude = 0.0;
  double longitude = 0.0;
  String name = '';

  // Fonction pour ajouter un marker dans Firestore
  Future<void> addMarkerToFirestore() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Ajouter les données dans Firestore
        await FirebaseFirestore.instance.collection('markers').add({
          'address': address,
          'category': category,
          'date': date,
          'latitude': latitude,
          'longitude': longitude,
          'name': name,
          'createdAt': DateTime.now(),
        });

        // Afficher un message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marker ajouté avec succès !')),
        );

        // Rediriger vers l'écran principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l’ajout : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Marker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Adresse'),
                  onSaved: (value) => address = value!,
                  validator: (value) => value!.isEmpty ? 'Entrez une adresse' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  onSaved: (value) => category = value!,
                  validator: (value) => value!.isEmpty ? 'Entrez une catégorie' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Date (AAAA-MM-JJ HH:MM)'),
                  onSaved: (value) => date = value!,
                  validator: (value) => value!.isEmpty ? 'Entrez une date valide' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => latitude = double.parse(value!),
                  validator: (value) => value!.isEmpty ? 'Entrez une latitude' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => longitude = double.parse(value!),
                  validator: (value) => value!.isEmpty ? 'Entrez une longitude' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nom'),
                  onSaved: (value) => name = value!,
                  validator: (value) => value!.isEmpty ? 'Entrez un nom' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: addMarkerToFirestore,
                  child: const Text('Ajouter le Marker'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
