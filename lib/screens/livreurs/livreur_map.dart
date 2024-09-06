import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../../models/livreur.dart';
import '../../models/delivery.dart'; // Modèle de livraison
import '../../services/livreur_service.dart';
import '../../services/delivery_service.dart'; // Service de livraison
import '../../services/manager_service.dart';
import '../../models/manager.dart';
import 'dart:async';
import '../../models/location.dart';

class LivreurMap extends StatefulWidget {
  @override
  _LivreurMapState createState() => _LivreurMapState();
}

class _LivreurMapState extends State<LivreurMap> {
  late LatLng deptLocation;
  late Timer _timer; // Le Timer pour déclencher les mises à jour
  final PopupController _popupLayerController = PopupController();
  List<Livreur> _livreurs = [];
  List<Delivery> _deliveries = []; // Liste des livraisons
  bool _showLivreurs = true;
  bool _showDeliveries = false;

  @override
  void initState() {
    super.initState();
    _loadCompanyLocation();
    _loadLivreurs();
    _loadDeliveries();
    _startLocationUpdates(); // Commencer les mises à jour
  }

  @override
  void dispose() {
     _timer?.cancel(); // Arrêter le Timer si non nul lorsque le widget est supprimé
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
    // Mettez à jour les positions des livreurs et livraisons toutes les 10 secondes
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
    } catch (e) {
      // Gestion des erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des livreurs')),
      );
    }
  }

  Future<void> _loadDeliveries() async {
    try {
      final deliveries = await DeliveryService.getDeliveries();
      setState(() {
        _deliveries = deliveries;
      });
    } catch (e) {
      // Gestion des erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des livraisons')),
      );
    }
  }

  // Fonction pour obtenir l'icône en fonction du moyen de transport du livreur
  Icon _getTransportIcon(String moyenDeTransport) {
    switch (moyenDeTransport) {
      case 'Vélo':
        return Icon(Icons.pedal_bike, color: Colors.blue, size: 25);
      case 'Moto':
        return Icon(Icons.delivery_dining, color: Colors.blue, size: 25);
      case 'Voiture':
        return Icon(Icons.directions_car, color: Colors.blue, size: 25);
      case 'Camion':
        return Icon(Icons.local_shipping, color: Colors.blue, size: 25);
      default:
        return Icon(Icons.person, color: Colors.blue, size: 25);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];

    if (_showLivreurs) {
      markers.addAll(_livreurs
          .where((livreur) => livreur.currentLocation != null)
          .map((livreur) {
        return Marker(
          width: 20.0,
          height: 20.0,
          point: LatLng(
            livreur.currentLocation!.latitude,
            livreur.currentLocation!.longitude,
          ),
          builder: (ctx) => GestureDetector(
            onTap: () {
              _popupLayerController.togglePopup(Marker(
                width: 30.0,
                height: 30.0,
                point: LatLng(
                  livreur.currentLocation!.latitude,
                  livreur.currentLocation!.longitude,
                ),
                builder: (ctx) => _getTransportIcon(livreur.moyenDeTransport),
              ));
            },
            child: _getTransportIcon(livreur.moyenDeTransport),
          ),
        );
      }).toList());
    }

    if (_showDeliveries) {
      markers.addAll(_deliveries.map((delivery) {
        return Marker(
          width: 20.0,
          height: 20.0,
          point: LatLng(
            delivery.deliveryAddress.latitude,
            delivery.deliveryAddress.longitude,
          ),
          builder: (ctx) => GestureDetector(
            onTap: () {
              _popupLayerController.togglePopup(Marker(
                width: 30.0,
                height: 30.0,
                point: LatLng(
                  delivery.deliveryAddress.latitude,
                  delivery.deliveryAddress.longitude,
                ),
                builder: (ctx) =>
                    Icon(Icons.person_pin_circle, color: Colors.red, size: 25),
              ));
            },
            child: Icon(Icons.person_pin_circle, color: Colors.red, size: 25),
          ),
        );
      }).toList());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Carte des Livraisons et Livreurs'),
        actions: [
          DropdownButton<String>(
            value: _showLivreurs && _showDeliveries ? 'Tout' : _showLivreurs ? 'Livreurs' : 'Point de livraisons',
            onChanged: (String? newValue) {
              setState(() {
                if (newValue == 'Livreurs') {
                  _showLivreurs = true;
                  _showDeliveries = false;
                } else if (newValue == 'Point de livraisons') {
                  _showLivreurs = false;
                  _showDeliveries = true;
                } else {
                  _showLivreurs = true;
                  _showDeliveries = true;
                }
              });
            },
            items: <String>['Livreurs', 'Point de livraisons', 'Tout']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
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
                  markerTapBehavior: MarkerTapBehavior.togglePopup(),
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (BuildContext context, Marker marker) {
                      final livreur = _livreurs.firstWhere(
                          (livreur) =>
                              LatLng(
                                livreur.currentLocation!.latitude,
                                livreur.currentLocation!.longitude,
                              ) ==
                              marker.point,
                          orElse: () => Livreur(id:'',userName:'',address:'',phone:'',firstName:'',name: '', email: '', moyenDeTransport: '', currentLocation: null));

                      final delivery = _deliveries.firstWhere(
                          (delivery) =>
                              LatLng(
                                delivery.deliveryAddress.latitude,
                                delivery.deliveryAddress.longitude,
                              ) ==
                              marker.point,
                          orElse: () => Delivery(
                            id:'',
                            clientName: '',
                            clientSurname: '',
                            clientEmail: '',
                            validationCode: '',
                            reference: '',
                            deliveryAddress: Location(latitude: 0, longitude: 0),
                            deliveryDateTime: DateTime.now(),
                            deliveryType: 'Standard',
                            status: 'Pending',
                            livreurId: '',
                            managerId: '',
                          ));

                      return livreur.name.isNotEmpty
                          ? Card(
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
                                     Text('Télephone : ${livreur.phone}'),
                                  ],
                                ),
                              ),
                            )
                          : Card(
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${delivery.clientName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Téléphone: ${delivery.clientSurname}'),
        Text('Email: ${delivery.clientEmail}'),
        // Styliser le statut
        Text(
          ' ${delivery.status}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getStatusColor(delivery.status), // Couleur du texte en fonction du statut
          ),
        ),
      ],
    ),
  ),
);

// Fonction pour obtenir la couleur en fonction du statut

                    },
                  ),
                ),
              ),
            ],
          ),
 Positioned(
  bottom: 10,
  right: 10,
  child: Container(
    color: Colors.white,
    padding: EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pedal_bike, color: Colors.blue),
            SizedBox(width: 5),
            Text('Vélo', style: TextStyle(color: Colors.blue)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.delivery_dining, color: Colors.blue),
            SizedBox(width: 5),
            Text('Moto', style: TextStyle(color: Colors.blue)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.directions_car, color: Colors.blue),
            SizedBox(width: 5),
            Text('Voiture', style: TextStyle(color: Colors.blue)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.blue),
            SizedBox(width: 5),
            Text('Camion', style: TextStyle(color: Colors.blue)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.person_pin_circle, color: Colors.red),
            SizedBox(width: 5),
            Text('Point de livraison', style: TextStyle(color: Colors.red)),
          ],
        ),
      ],
    ),
  ),
),

        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
  switch (status) {
    case 'En attente':
      return Colors.orange; // Couleur pour le statut "En attente"
    case 'En cours':
      return Colors.blue; // Couleur pour le statut "En cours"
    case 'Terminé':
      return Colors.green; // Couleur pour le statut "Terminé"
    case 'Annulé':
      return Colors.red; // Couleur pour le statut "Annulé"
    default:
      return Colors.black; // Couleur par défaut si le statut est inconnu
  }
}
}
