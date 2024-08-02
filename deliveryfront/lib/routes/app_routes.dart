import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/livreurs/Livreurs_details_screen.dart';
import '../screens/livreurs/add_livreur_screen.dart';
import '../screens/livreurs/livreur_screen.dart';
import '../screens/livreurs/edit_livreur_screen.dart';
class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/': (context) => LoginScreen(),
      '/register': (context) => RegisterPage(),
      '/home' : (context) => HomeScreen(),
      '/livreurs': (context) => LivreursScreen(),
      '/add-livreur': (context) => AddLivreurScreen(),
      '/livreur/:id': (context) => LivreurDetailsScreen(
        livreurId: ModalRoute.of(context)!.settings.arguments as String,
      ),
      '/edit-livreur/:id': (context) => EditLivreurScreen(
        livreurId: ModalRoute.of(context)!.settings.arguments as String,
      ),
    };
  }
}