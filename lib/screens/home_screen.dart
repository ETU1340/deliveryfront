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
      _companyName = manager!.companyName;
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
                  _companyName ?? 'Nom de la société',
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
                      onPressed: () => _onMenuItemSelected(2),
                      child: Text(
                        'Livraisons',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _onMenuItemSelected(3),
                      child: Text(
                        'Planification des Livraisons',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _onMenuItemSelected(4), // Sélection de la discussion
                      child: Text(
                        'Discussion',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await AuthService.logout(context);
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
