import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/livreurs/livreur_screen.dart';
class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/': (context) => LoginScreen(),
      '/register': (context) => RegisterPage(),
      '/home' : (context) => HomeScreen(),
      '/livreurs': (context) => LivreursScreen(),
    };
  }
}