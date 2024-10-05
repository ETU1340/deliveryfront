import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';
import '../../models/manager.dart';
import '../../services/manager_service.dart';
import '../../services/delivery_service.dart';
import '../../models/delivery.dart';
import '../../models/location.dart';

class DeliveryPlanningScreen extends StatefulWidget {
  @override
  _DeliveryPlanningScreenState createState() => _DeliveryPlanningScreenState();
}

class _DeliveryPlanningScreenState extends State<DeliveryPlanningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _startDateController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientSurnameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _validationCodeController = TextEditingController();
  final _referenceController = TextEditingController();
  LatLng? _selectedLocation;
  Livreur? _selectedLivreur;
  List<Livreur> _livreurs = [];
  late LatLng deptLocation;
  bool isLoadingLivreurs = true;
  Duration? _selectedDuration;
  
  // Nouveau : Variable pour le type de transport sélectionné
  String? _selectedTransportType;

  // Liste des types de transport
  final List<String> transportTypes = ['Tous', 'Vélo', 'Moto', 'Voiture', 'Camion'];

  @override
  void initState() {
    super.initState();
    _loadCompanyLocation();
  }

  Future<void> _loadCompanyLocation() async {
    Manager? manager = await ManagerService.getManagerSession();
    if (manager != null) {
      setState(() {
        deptLocation = LatLng(manager.location.latitude, manager.location.longitude);
      });
    }
  }

  Future<void> _loadLivreurs(DateTime startDate, DateTime endDate) async {
    setState(() {
      isLoadingLivreurs = true; // Pour gérer l'état de chargement
    });
    Manager? manager = await ManagerService.getManagerSession();
    try {
      // Appeler le service avec les dates de début et de fin
      _livreurs = await LivreurService.getLivreursDisponibles(
          manager!.id, startDate, endDate);

      // Si un type de transport est sélectionné, filtrer les livreurs
      if (_selectedTransportType != null && _selectedTransportType != 'Tous') {
        _livreurs = _livreurs.where((livreur) {
          return livreur.moyenDeTransport == _selectedTransportType;
        }).toList();
      }

      setState(() {
        isLoadingLivreurs = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du chargement des livreurs disponibles')),
      );
      setState(() {
        isLoadingLivreurs = false;
      });
    }
  }

  void _openMapModal() async {
    final selectedLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: FlutterMap(
              options: MapOptions(
                center: deptLocation,
                zoom: 13.0,
                onTap: (_, point) {
                  Navigator.pop(context, point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
        _addressController.text = 'Lat: ${selectedLocation.latitude}, Lon: ${selectedLocation.longitude}';
      });
    }
  }

  Future<void> _planDelivery() async {
    if (_formKey.currentState?.validate() ?? false) {
      DateTime deliveryStartDate = DateTime.parse(_startDateController.text);
      DateTime deliveryEndDate = deliveryStartDate.add(_selectedDuration!); // Calcul de la date de fin
      Manager? manager = await ManagerService.getManagerSession();

      final delivery = Delivery(
        id: '',
        clientName: _clientNameController.text,
        clientSurname: _clientSurnameController.text,
        clientEmail: _clientEmailController.text,
        validationCode: _validationCodeController.text,
        reference: 'LIV - '+_referenceController.text,
        deliveryAddress: Location(
          latitude: _selectedLocation?.latitude ?? 0.0,
          longitude: _selectedLocation?.longitude ?? 0.0,
        ),
        deliveryDateTime: deliveryStartDate,
        deliveryEndDateTime: deliveryEndDate,
        status: 'En attente',
        livreurId: _selectedLivreur!.id,
        managerId: manager!.id,
      );

      final success = await DeliveryService.createDelivery(delivery);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Livraison planifiée avec succès!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la planification de la livraison')),
        );
      }
    }
  }

  void _selectDuration(BuildContext context) async {
    final pickedDuration = await showDialog<Duration>(
      context: context,
      builder: (context) {
        Duration selectedDuration = Duration(hours: 1); // Durée par défaut
        return AlertDialog(
          title: Text('Sélectionnez la durée de la livraison'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Heures'),
              DropdownButton<int>(
                value: selectedDuration.inHours,
                onChanged: (int? newHours) {
                  if (newHours != null) {
                    setState(() {
                      selectedDuration = Duration(hours: newHours, minutes: selectedDuration.inMinutes % 60);
                    });
                  }
                },
                items: List.generate(12, (index) => index + 1)
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value heure(s)'),
                  );
                }).toList(),
              ),
              Text('Minutes'),
              DropdownButton<int>(
                value: selectedDuration.inMinutes % 60,
                onChanged: (int? newMinutes) {
                  if (newMinutes != null) {
                    setState(() {
                      selectedDuration = Duration(hours: selectedDuration.inHours, minutes: newMinutes);
                    });
                  }
                },
                items: List.generate(60, (index) => index)
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value minute(s)'),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () {
                Navigator.of(context).pop(selectedDuration);
              },
            ),
          ],
        );
      },
    );

    if (pickedDuration != null) {
      setState(() {
        _selectedDuration = pickedDuration;
      });

      // Si la date de début est déjà sélectionnée, charger les livreurs
      if (_startDateController.text.isNotEmpty) {
        DateTime startDate = DateTime.parse(_startDateController.text);
        DateTime endDate = startDate.add(_selectedDuration!);
        _loadLivreurs(startDate, endDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planification des Livraisons'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planifiez une nouvelle livraison',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _clientNameController,
                            decoration: InputDecoration(
                              labelText: 'Nom du client',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom du client';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _clientEmailController,
                            decoration: InputDecoration(
                              labelText: 'Email du client',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer l\'email du client';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Adresse de livraison',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.map),
                                onPressed: _openMapModal,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer une adresse de livraison';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _clientSurnameController,
                            decoration: InputDecoration(
                              labelText: 'Téléphone',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le téléphone du client';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _validationCodeController,
                            decoration: InputDecoration(
                              labelText: 'Code de validation',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un code de validation';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _referenceController,
                            decoration: InputDecoration(
                              labelText: 'Référence de livraison',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer la référence de l\'objet';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Date et Heure début',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );

                            if (pickedTime != null) {
                              DateTime finalDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              setState(() {
                                _startDateController.text = finalDateTime.toString();
                              });

                              // Si la durée est déjà sélectionnée, charger les livreurs
                              if (_selectedDuration != null) {
                                DateTime endDate = finalDateTime.add(_selectedDuration!);
                                _loadLivreurs(finalDateTime, endDate);
                              }
                            }
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer la date et heure de début';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDuration(context), // Ouvrir le modal pour sélectionner la durée
                        child: Text(
                          _selectedDuration != null
                              ? 'Durée: ${_selectedDuration!.inHours} heures ${_selectedDuration!.inMinutes % 60} minutes'
                              : 'Sélectionner la durée',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // Dropdown pour sélectionner le type de transport
                Text(
                  'Sélectionnez un type de transport',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedTransportType ?? 'Tous', // 'Tous' par défaut
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTransportType = newValue;
                    });

                    // Filtrer les livreurs disponibles après sélection du type de transport
                    if (_startDateController.text.isNotEmpty && _selectedDuration != null) {
                      DateTime startDate = DateTime.parse(_startDateController.text);
                      DateTime endDate = startDate.add(_selectedDuration!);
                      _loadLivreurs(startDate, endDate);
                    }
                  },
                  items: transportTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                
                SizedBox(height: 20),
                Text(
                  'Sélectionnez un livreur',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                isLoadingLivreurs
                    ? Center(child: CircularProgressIndicator()) // Afficher le loader pendant le chargement
                    : Container(
                        height: 200, // Limite la hauteur pour faciliter le défilement
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListView.builder(
                          itemCount: _livreurs.length,
                          itemBuilder: (context, index) {
                            Livreur livreur = _livreurs[index];
                            return ListTile(
                              title: Text('${livreur.name} (${livreur.moyenDeTransport})'),
                              subtitle: Text(livreur.email),
                              trailing: Radio<Livreur>(
                                value: livreur,
                                groupValue: _selectedLivreur,
                                onChanged: (Livreur? value) {
                                  setState(() {
                                    _selectedLivreur = value;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _planDelivery,
                  child: Text('Planifier la livraison'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
