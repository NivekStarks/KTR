import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class DeleteMarkerScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchMarkers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('markers').get();
    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc['name'],
            })
        .toList();
  }

  Future<void> _deleteMarker(BuildContext context, String id) async {
    // Supprime le marker dans Firestore
    await FirebaseFirestore.instance.collection('markers').doc(id).delete();

    // Affiche un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marker supprimé.')),
    );

    // Retourne à la page principale
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supprimer un Marker'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMarkers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> markers = snapshot.data!;
          if (markers.isEmpty) {
            return Center(child: Text('Aucun marker trouvé.'));
          }

          return ListView.builder(
            itemCount: markers.length,
            itemBuilder: (context, index) {
              String id = markers[index]['id'];
              String name = markers[index]['name'];

              return ListTile(
                title: Text(name),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteMarker(context, id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
