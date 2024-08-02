import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_urls.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse(ApiUrls.getLivreurs), // Remplacez par l'URL de votre API pour obtenir les statistiques
      headers: <String, String>{
        'x-auth-token': '$token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _statistics = jsonDecode(response.body);
      });
    } else {
      // Gérer les erreurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: _statistics.isEmpty
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  // Affichage des statistiques
                  Text('Total Deliveries: ${_statistics['totalDeliveries']}'),
                  Text('Active Deliverers: ${_statistics['activeDeliverers']}'),
                  // Ajoutez d'autres statistiques selon vos besoins
                ],
              ),
      ),
    );
  }
}
