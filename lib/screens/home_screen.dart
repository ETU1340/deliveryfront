import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/livreurs/livreur_screen.dart';
import '../screens/livreurs/livreur_map.dart';
import '../services/manager_service.dart';
import '../models/manager.dart';
import './delivery/delivery_planning_screen.dart';
import './delivery/delivery_list_screen.dart';
import './discu_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _companyName;
  final List<Widget> _pages = [
    LivreursScreen(),
    LivreurMap(),
    DeliveryListScreen(),
    DeliveryPlanningScreen(),
    ManagerChatScreen(), // Ajout de l'écran de discussion
  ];

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
  }

  Future<void> _loadCompanyName() async {
    Manager? manager = await ManagerService.getManagerSession();
    setState(() {
      _companyName = manager?.companyName ?? 'Nom de la société';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header bar with company name and menu
          Container(
            color: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Company name on the left
                Text(
                  _companyName ?? 'Nom de la société',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Menu buttons on the right
                Row(
                  children: [
                    _buildMenuButton('Livreurs', 0),
                    _buildMenuButton('Visualisation', 1),
                    _buildMenuButton('Livraisons', 2),
                    _buildMenuButton('Planification', 3),
                    _buildMenuButton('Discussion', 4),
                    _buildLogoutButton(),
                  ],
                ),
              ],
            ),
          ),
          // Display the selected page
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

  // Function to create a reusable menu button
  Widget _buildMenuButton(String title, int index) {
    return TextButton(
      onPressed: () => _onMenuItemSelected(index),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  // Function to create the logout button
  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: () async {
        await AuthService.logout(context);
      },
      child: Text(
        'Logout',
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
