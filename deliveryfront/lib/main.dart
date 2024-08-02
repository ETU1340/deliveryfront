import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'config/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Management App',
      theme: appTheme(),
      initialRoute: '/',
      routes: AppRoutes.getRoutes(),
    );
  }
}
