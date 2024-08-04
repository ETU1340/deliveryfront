import 'package:flutter/material.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';
import './livreur_dialog.dart';
import './livreur_details_screen.dart';

class LivreursScreen extends StatefulWidget {
  @override
  _LivreursScreenState createState() => _LivreursScreenState();
}

class _LivreursScreenState extends State<LivreursScreen> {
  late Future<List<Livreur>> _livreursFuture;
  List<Livreur> _livreurs = [];

  @override
  void initState() {
    super.initState();
    _livreursFuture = LivreurService.getLivreurs();
    _loadLivreurs();
  }

  Future<void> _loadLivreurs() async {
    try {
      final livreurs = await LivreurService.getLivreurs();
      setState(() {
        _livreurs = livreurs;
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load livreurs'),
      ));
    }
  }

  void _createOrUpdateLivreur([Livreur? livreur]) {
    showDialog(
      context: context,
      builder: (context) => LivreurDialog(
        livreur: livreur,
        onSave: (livreur) async {
          try {
            if (livreur.id.isEmpty) {
              await LivreurService.createLivreur(livreur);
            } else {
              await LivreurService.updateLivreur(livreur);
            }
            await _loadLivreurs();
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to save livreur'),
            ));
          }
        },
      ),
    );
  }

  void _deleteLivreur(String id) async {
    try {
      await LivreurService.deleteLivreur(id);
      await _loadLivreurs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete livreur'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livreurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createOrUpdateLivreur(),
          ),
        ],
      ),
      body: FutureBuilder<List<Livreur>>(
        future: _livreursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load livreurs'));
          } else {
            return ListView.builder(
              itemCount: _livreurs.length,
              itemBuilder: (context, index) {
                final livreur = _livreurs[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(
                        livreur.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(livreur.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _createOrUpdateLivreur(livreur),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteLivreur(livreur.id),
                          ),
                          
                        ],
                      ),
                        onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LivreurDetailsScreen(livreur: livreur),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
