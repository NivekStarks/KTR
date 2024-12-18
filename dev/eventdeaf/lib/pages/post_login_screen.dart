import 'package:flutter/material.dart';
import 'add_marker_screen.dart';
import 'delete_marker_screen.dart';

class PostLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actions après connexion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMarkerScreen()),
                );
              },
              child: Text('Ajouter un Marker'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteMarkerScreen()),
                );
              },
              child: Text('Supprimer un Marker'),
            ),
          ],
        ),
      ),
    );
  }
}
