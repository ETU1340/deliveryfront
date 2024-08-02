import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import '../services/livreur_service.dart';
import '../models/livreur.dart';

class LivreursScreen extends StatefulWidget {
  @override
  _LivreursPageState createState() => _LivreursPageState();
}

class _LivreursPageState extends State<LivreursScreen> {
  final LivreurService _livreurService = LivreurService();
  late Future<List<Livreur>> _futureLivreurs;

  @override
  void initState() {
    super.initState();
    _futureLivreurs = _livreurService.fetchLivreurs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livreurs'),
      ),
      body: FutureBuilder<List<Livreur>>(
        future: _futureLivreurs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No livreurs found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final livreur = snapshot.data![index];
                return ListTile(
                  title: Text(livreur.name),
                  subtitle: Text(livreur.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/editLivreur',
                            arguments: livreur,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _livreurService.deleteLivreur(livreur.id);
                          setState(() {
                            _futureLivreurs = _livreurService.fetchLivreurs();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addLivreur');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}