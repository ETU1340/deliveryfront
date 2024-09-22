import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './register_screen.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _ManagerLoginPageState createState() => _ManagerLoginPageState();
}

class _ManagerLoginPageState extends State<LoginScreen> {
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userName = _userNameController.text;
      final password = _passwordController.text;

      final success = await AuthService.login(userName, password);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connexion avec succès")),
        );
        Navigator.pushNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Compte introuvable")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Background in light blue
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or icon at the top
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.blue, // Main color for icon
                ),
                SizedBox(height: 20),
                // Title
                Text(
                  'Delivery',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900], // Darker blue for text
                  ),
                ),
                SizedBox(height: 20),
                // Form starts here
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _userNameController,
                        label: 'Nom d`utilisateur',
                        obscureText: false,
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      // Login button
                      CustomButton(
                        text: 'Login',
                        onPressed: _login,
                      ),
 
                      SizedBox(height: 20),
                      // Register option
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                        child: Text(
                          'Vous n\'avez pas de compte ? Inscrivez-vous',
                          style: TextStyle(
                            color: Colors.blue[800],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
