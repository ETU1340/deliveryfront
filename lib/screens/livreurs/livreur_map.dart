import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart'; // Assurez-vous d'importer correctement le service

class LivreurMap extends StatefulWidget {
  @override
  _LivreurMapState createState() => _LivreurMapState();
}

class _LivreurMapState extends State<LivreurMap> {
  late Future<List<Livreur>> _livreursFuture;

  @override
  void initState() {
    super.initState();
    _livreursFuture = LivreurService.getLivreurs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Livreur>>(
      future: _livreursFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur lors du chargement des livreurs'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucun livreur trouvé'));
        } else {
          List<Livreur> livreurs = snapshot.data!;
          return FlutterMap(
            options: MapOptions(
              center: LatLng(-18.8792, 47.5079), // Centre sur Antananarivo, Madagascar
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: livreurs
                    .where((livreur) => livreur.currentLocation != null)
                    .map((livreur) {
                  return Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(
                      livreur.currentLocation!.latitude,
                      livreur.currentLocation!.longitude,
                    ),
                    builder: (ctx) => Container(
                      child: Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }
      },
    );
  }
}
