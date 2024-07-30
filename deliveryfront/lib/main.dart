import 'package:flutter/material.dart';
import 'login/manager_login_page.dart';
import 'login/register_page.dart';
import './manager/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ManagerLoginPage(),
       routes: {
        '/register': (context) => RegisterPage(),
          '/login': (context) => ManagerLoginPage(),
        '/home': (context) => HomePage(),
        // Vous pouvez ajouter d'autres routes ici
      },
    );
  }
}
