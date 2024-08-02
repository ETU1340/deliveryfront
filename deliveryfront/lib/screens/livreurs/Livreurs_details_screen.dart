import 'package:flutter/material.dart';
import '../../services/livreur_service.dart'; // Assurez-vous que ce fichier existe
import '../../models/livreur.dart';
class LivreurDetailsScreen extends StatefulWidget {
  final String livreurId;

  LivreurDetailsScreen({required this.livreurId});

  @override
  _LivreurDetailsPageState createState() => _LivreurDetailsPageState();
}

class _LivreurDetailsPageState extends State<LivreurDetailsScreen> {
  late Livreur _livreur;
  bool _isLoading = true;
  final LivreurService _livreurService = LivreurService();

  @override
  void initState() {
    super.initState();
    _fetchLivreur();
  }

  Future<void> _fetchLivreur() async {
    final livreur = await _livreurService.getLivreurById(widget.livreurId);
    setState(() {
      _livreur = livreur;
      _isLoading = false;
    });
  }

  Future<void> _deleteLivreur() async {
    final success = await _livreurService.deleteLivreur(widget.livreurId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Livreur deleted successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete livreur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Livreur Details'),
          backgroundColor: Colors.blue,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Livreur Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${_livreur['name']}'),
            Text('Email: ${_livreur['email']}'),
            Text('Address: ${_livreur['address']}'),
            Text('Phone: ${_livreur['phone']}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-livreur/${_livreur['_id']}',
                );
              },
              child: Text('Edit Livreur'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _deleteLivreur,
              child: Text('Delete Livreur'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
