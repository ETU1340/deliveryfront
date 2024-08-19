import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/livreurs/livreur_screen.dart';
import '../screens/livreurs/livreur_map.dart'; // Importez le fichier LivreurMap

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    LivreursScreen(),
    LivreurMap(), // Affichage de la carte des livreurs
  ];

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Manager Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _onMenuItemSelected(0),
                      child: Text(
                        'Dashboard',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _onMenuItemSelected(1),
                      child: Text(
                        'Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _onMenuItemSelected(0),
                      child: Text(
                        'Livreurs',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _onMenuItemSelected(1),
                      child: Text(
                        'Carte des Livreurs',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await AuthService.logout(context);
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
