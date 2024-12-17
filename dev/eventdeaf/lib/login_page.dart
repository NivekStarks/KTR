import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'map_with_markers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;  // Pour afficher un indicateur de chargement

  // Fonction de connexion
  Future<void> _login() async {
    setState(() {
      _isLoading = true;  // Affichage de l'indicateur de chargement
    });

    try {
      // Connexion avec l'email et le mot de passe
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Si la connexion réussit, rediriger vers la page d'accueil
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // En cas d'erreur de connexion
      setState(() {
        _isLoading = false;  // Masquer l'indicateur de chargement
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.message}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    String email;
    String password;
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) => email = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              onChanged: (value) => password = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Se Connecter')),
          ],
        ),
      ),
    );
  }
}
