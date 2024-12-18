import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:flutter/material.dart';
import 'post_login_screen.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Authenticate user with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _usernameController.text,
          password: _passwordController.text,
        );

        // If the login is successful, navigate to the PostLoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PostLoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        // Handle errors during login
        String errorMessage = "Une erreur s'est produite. Veuillez réessayer.";

        if (e.code == 'user-not-found') {
          errorMessage = 'Aucun utilisateur trouvé pour cet e-mail.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Mauvais mot de passe fourni.';
        }

        // Show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur de connexion'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Entrez votre email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Entrez votre mot de passe' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
