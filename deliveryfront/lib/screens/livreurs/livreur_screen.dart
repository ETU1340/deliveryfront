import 'package:flutter/material.dart';
import '../../services/livreur_service.dart';
import '../home_screen.dart';

class LivreursScreen extends StatelessWidget {
    final LivreurService _livreurService = LivreurService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livreurs'),
        backgroundColor: Colors.blue,
      ),
      drawer: HomeScreen().buildDrawer(context),
      body: FutureBuilder(
        future: _livreurService.fetchLivreurs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return Center(child: Text('No livreurs found.'));
          }

          final livreurs = snapshot.data as List;
          return ListView.builder(
            itemCount: livreurs.length,
            itemBuilder: (context, index) {
              final livreur = livreurs[index];
              return ListTile(
                title: Text(livreur['name']),
                subtitle: Text(livreur['email']),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/livreur/${livreur['_id']}',
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-livreur');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
