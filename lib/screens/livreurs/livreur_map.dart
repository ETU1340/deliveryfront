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
  late Timer _timer;
  final PopupController _popupLayerController = PopupController();
  List<Livreur> _livreurs = [];
  List<Delivery> _deliveries = [];
  bool _showLivreurs = true;
  bool _showDeliveries = false;

  @override
  void initState() {
    super.initState();
    _loadCompanyLocation();
    _loadLivreurs();
    _loadDeliveries();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des livreurs')),
      );
    }
  }

  Future<void> _loadDeliveries() async {
    try {
      final deliveries = await DeliveryService.getDeliveriesNow();
      setState(() {
        _deliveries = deliveries;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des livraisons')),
      );
    }
  }

  // Fonction pour obtenir l'icône en fonction du moyen de transport du livreur
  Icon _getTransportIcon(String moyenDeTransport) {
    switch (moyenDeTransport) {
      case 'Vélo':
        return Icon(Icons.pedal_bike, color: Colors.blue, size: 20);
      case 'Moto':
        return Icon(Icons.delivery_dining, color: Colors.blue, size: 20);
      case 'Voiture':
        return Icon(Icons.directions_car, color: Colors.blue, size: 20);
      case 'Camion':
        return Icon(Icons.local_shipping, color: Colors.blue, size: 20);
      default:
        return Icon(Icons.person, color: Colors.blue, size: 20);
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
                    Icon(Icons.person_pin_circle, color: Colors.green, size: 25),
              ));
            },
            child: Icon(Icons.person_pin_circle, color: Colors.green, size: 25),
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
                      // Déterminer si le marker correspond à un livreur
                      final livreur = _livreurs.firstWhere(
                          (livreur) =>
                              livreur.currentLocation != null &&
                              _arePointsEqual(
                                LatLng(
                                  livreur.currentLocation!.latitude,
                                  livreur.currentLocation!.longitude,
                                ),
                                marker.point,
                              ),
                          orElse: () => Livreur(
                              id: '',
                              userName: '',
                              address: '',
                              phone: '',
                              firstName: '',
                              name: '',
                              email: '',
                              moyenDeTransport: '',
                              currentLocation: null));

                      if (livreur.id.isNotEmpty) {
                        // Récupérer la livraison en cours pour ce livreur
                        final Delivery? currentDelivery = _getCurrentDeliveryForLivreur(livreur);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${livreur.name} ${livreur.firstName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Transport: ${livreur.moyenDeTransport}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Téléphone: ${livreur.phone}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Livraison en cours:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  currentDelivery?.reference ?? "Aucune",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: currentDelivery != null ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Si le marker correspond à une livraison
                      final delivery = _deliveries.firstWhere(
                          (delivery) =>
                              _arePointsEqual(
                                LatLng(
                                  delivery.deliveryAddress.latitude,
                                  delivery.deliveryAddress.longitude,
                                ),
                                marker.point,
                              ),
                          orElse: () => Delivery(
                                id: '',
                                clientName: '',
                                clientSurname: '',
                                clientEmail: '',
                                validationCode: '',
                                reference: '',
                                deliveryAddress: Location(latitude: 0, longitude: 0),
                                deliveryDateTime: DateTime.now(),
                                deliveryEndDateTime: DateTime.now(),
                                status: 'Pending',
                                livreurId: '',
                                managerId: '',
                              ));

                      return delivery.clientName.isNotEmpty
                          ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${delivery.clientName}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Téléphone: ${delivery.clientSurname}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Email: ${delivery.clientEmail}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Référence: ${delivery.reference}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Statut: ${delivery.status}',
                                      style: TextStyle(
                                        color: _getStatusColor(delivery.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox.shrink();
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
                      Icon(Icons.person_pin_circle, color: Colors.green),
                      SizedBox(width: 5),
                      Text('Point de livraison', style: TextStyle(color: Colors.green)),
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

  bool _arePointsEqual(LatLng point1, LatLng point2, {double tolerance = 0.0001}) {
    return (point1.latitude - point2.latitude).abs() < tolerance &&
        (point1.longitude - point2.longitude).abs() < tolerance;
  }

  Delivery? _getCurrentDeliveryForLivreur(Livreur livreur) {
    final now = DateTime.now().toUtc().add(Duration(hours: 3));
    print('--- Vérification des livraisons pour le livreur: ${livreur.name} ${livreur.firstName} ---');
    print('Heure actuelle ajustée (UTC+3): $now');

    for (var delivery in _deliveries) {
      final deliveryStartUtc = delivery.deliveryDateTime.toUtc();
      final deliveryEndUtc = delivery.deliveryEndDateTime.toUtc();

      print('Évaluation de la livraison: ${delivery.reference} | Statut: ${delivery.status} | '
            'ID Livreur: ${delivery.livreurId} | Début (UTC): $deliveryStartUtc | Fin (UTC): $deliveryEndUtc');

      if (delivery.livreurId == livreur.id &&
          delivery.status == 'En cours' &&
          deliveryStartUtc.isBefore(now) &&
          deliveryEndUtc.isAfter(now)) {
        print('>>> Livraison en cours trouvée: ${delivery.reference}');
        return delivery;
      }
    }

    print('Aucune livraison en cours trouvée pour le livreur: ${livreur.id}');
    return null;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En attente':
        return Colors.orange;
      case 'En cours':
        return Colors.blue;
      case 'Terminé':
        return Colors.green;
      case 'Annulé':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
