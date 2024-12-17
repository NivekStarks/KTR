import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Page principale avec carte et ajout de marqueurs
import 'login_page.dart'; // Page de connexion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carte des Événements',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthGate(), // Page d'entrée
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first, // Vérifie l'état d'authentification
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Afficher un indicateur de chargement pendant la vérification de l'état de connexion
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Afficher un message d'erreur si l'état de l'authentification échoue
          return const Center(child: Text('Erreur de connexion'));
        } else if (snapshot.hasData) {
          // Si l'utilisateur est connecté, aller à la page d'accueil
          return const HomePage();
        } else {
          // Si l'utilisateur n'est pas connecté, aller à la page de connexion
          return const LoginPage();
        }
      },
    );
  }
}
