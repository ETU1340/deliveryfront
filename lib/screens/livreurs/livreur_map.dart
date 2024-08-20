import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';
import '../../services/manager_service.dart';
import '../../models/manager.dart';
import 'dart:async';

class LivreurMap extends StatefulWidget {
  @override
  _LivreurMapState createState() => _LivreurMapState();
}


class _LivreurMapState extends State<LivreurMap> {
  late LatLng deptLocation;
  late Timer _timer; // Le Timer pour déclencher les mises à jour
  final PopupController _popupLayerController = PopupController();
  List<Livreur> _livreurs = [];

  @override
  void initState() {
    super.initState();
    _loadCompanyLocation();
    _loadLivreurs();
    _startLocationUpdates(); // Commencer les mises à jour
  }

  @override
  void dispose() {
    _timer.cancel(); // Arrêter le Timer lorsque le widget est supprimé
    super.dispose();
  }

  Future<void> _loadCompanyLocation() async {
    Manager? manager = await ManagerService.getManagerSession();
    if (manager != null) {
      setState(() {
        deptLocation = LatLng(manager.location.latitude, manager.location.longitude);
      });
    }
  }

  void _startLocationUpdates() {
    // Mettez à jour les positions des livreurs toutes les 10 secondes
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _loadLivreurs();
    });
  }

  Future<void> _loadLivreurs() async {

    try {
      final livreurs = await LivreurService.getLivreurs();
      setState(() {
        _livreurs = livreurs;
      });
      print("location setter");
    } catch (e) {
      // Gestion des erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des livreurs')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
          List<Marker> markers = _livreurs
              .where((livreur) => livreur.currentLocation != null)
              .map((livreur) {
            return Marker(
              width: 50.0,
              height: 50.0,
              point: LatLng(
                livreur.currentLocation!.latitude,
                livreur.currentLocation!.longitude,
              ),
              builder: (ctx) => GestureDetector(
                onTap: () {
                  _popupLayerController.togglePopup(Marker(
                    width: 50.0,
                    height: 50.0,
                    point: LatLng(
                      livreur.currentLocation!.latitude,
                      livreur.currentLocation!.longitude,
                    ),
                    builder: (ctx) => Icon(Icons.location_on, color: Colors.red, size: 30),
                  ));
                },
                child: Icon(Icons.location_on, color: Colors.red, size: 30),
              ),
            );
          }).toList();

          return FlutterMap(
            options: MapOptions(
              center: deptLocation,
              zoom: 13.0,
              onTap: (_, __) => _popupLayerController.hideAllPopups(),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  markers: markers,
                  popupController: _popupLayerController,
                  markerTapBehavior: MarkerTapBehavior.togglePopup(), // Directly assign the behavior here
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (BuildContext context, Marker marker) {
                      final livreur = _livreurs.firstWhere((livreur) =>
                          LatLng(
                            livreur.currentLocation!.latitude,
                            livreur.currentLocation!.longitude,
                          ) ==
                          marker.point);

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${livreur.name} ${livreur.firstName}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Transport: ${livreur.moyenDeTransport}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      }
