import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/delivery.dart';
import '../../services/delivery_service.dart';
import '../../models/livreur.dart';

class DeliveryListScreen extends StatefulWidget {
  @override
  _DeliveryListScreenState createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  List<Delivery> _deliveries = [];
  List<Delivery> _filteredDeliveries = [];
  String _searchQuery = '';
  String? _selectedStatus;
  DateTime? _selectedDate;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    try {
      _deliveries = await DeliveryService.getDeliveries();
      setState(() {
        _filteredDeliveries = _deliveries;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du chargement des livraisons')),
      );
    }
  }

  void _filterDeliveries() {
    setState(() {
      _filteredDeliveries = _deliveries.where((delivery) {
        bool matchesSearchQuery = delivery.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesStatus = _selectedStatus == null || delivery.status == _selectedStatus;
        bool matchesDate = _selectedDate == null || 
            delivery.deliveryDateTime.toString().substring(0, 10) == _selectedDate.toString().substring(0, 10);
        return matchesSearchQuery && matchesStatus && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Livraisons'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  child: PaginatedDataTable(
                    header: Text('Liste des Livraisons'),
                    rowsPerPage: _rowsPerPage,
                    availableRowsPerPage: [5, 10, 20],
                    onRowsPerPageChanged: (value) {
                      setState(() {
                        _rowsPerPage = value ?? PaginatedDataTable.defaultRowsPerPage;
                      });
                    },
                    columns: [
                      DataColumn(label: Text('Nom du Client')),
                      DataColumn(label: Text('Date de Livraison')),
                      DataColumn(label: Text('Statut')),
                      DataColumn(label: Text('Livreur')),
                      DataColumn(label: Text('Actions')),
                    ],
                    source: _DeliveryDataSource(
                      deliveries: _filteredDeliveries,
                      context: context,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Rechercher par nom du client',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
              _filterDeliveries();
            });
          },
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: ['En attente', 'En cours', 'Terminé', 'Annulé'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                    _filterDeliveries();
                  });
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date de Livraison',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _filterDeliveries();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}class _DeliveryDataSource extends DataTableSource {
  final List<Delivery> deliveries;
  final BuildContext context;

  _DeliveryDataSource({required this.deliveries, required this.context});

  @override
  DataRow getRow(int index) {
    final delivery = deliveries[index];
    Color rowColor;

    // Attribuer des couleurs en fonction du statut de la livraison
    switch (delivery.status) {
      case 'En attente':
        rowColor = Colors.orange.withOpacity(0.2);
        break;
      case 'En cours':
        rowColor = Colors.blue.withOpacity(0.2);
        break;
      case 'Terminé':
        rowColor = Colors.green.withOpacity(0.2);
        break;
      case 'Annulé':
        rowColor = Colors.red.withOpacity(0.2);
        break;
      default:
        rowColor = Colors.grey.withOpacity(0.2);
    }

    return DataRow.byIndex(
      index: index,
      color: MaterialStateProperty.all(rowColor),
      cells: [
        DataCell(Text(delivery.clientName)),
        DataCell(Text('${delivery.deliveryDateTime} à ${delivery.deliveryEndDateTime}')),
        DataCell(Text(delivery.status)),
        DataCell(Text(delivery.livreur != null ? delivery.livreur!.name : 'Non assigné')),
        DataCell(Row(
          children: [
            // Détails de la livraison dans un modal
            IconButton(
              icon: Icon(Icons.info, color: Colors.green),
              onPressed: () {
                _showDeliveryDetailsModal(context, delivery);
              },
            ),
            // Validation de la livraison
            if (delivery.status == 'En cours')
              IconButton(
                icon: Icon(Icons.check_circle, color: Colors.blue),
                onPressed: () {
                  _validateDelivery(context, delivery, index);
                },
              ),
            // Annuler la livraison si elle n'est ni en cours ni terminée
            if (delivery.status == 'En attente')
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  _cancelDelivery(context, delivery, index);
                },
              ),
          ],
        )),
      ],
    );
  }

  // Fonction pour afficher les détails de la livraison dans un modal stylé
  void _showDeliveryDetailsModal(BuildContext context, Delivery delivery) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails de la livraison',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Divider(),
                SizedBox(height: 8),
                _buildDetailRow('Nom du client', delivery.clientName),
                _buildDetailRow('Téléphone du client', delivery.clientSurname),
                _buildDetailRow('Email du client', delivery.clientEmail),
                _buildDetailRow('Adresse de livraison', '${delivery.deliveryAddress.latitude}, ${delivery.deliveryAddress.longitude}'),
                _buildDetailRow('Date de début', delivery.deliveryDateTime.toString()),
                _buildDetailRow('Date de fin', delivery.deliveryEndDateTime.toString()),
                _buildDetailRow('Statut', delivery.status),
                if (delivery.livreur != null)
                  _buildDetailRow('Livreur assigné', delivery.livreur!.name),
                  
                // Mise en évidence du code de validation
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Text(
                        'Code de validation: ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      Expanded(
                        child: SelectableText(
                          delivery.validationCode,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: Colors.blue),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: delivery.validationCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Code de validation copié !')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Fermer', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fonction pour construire chaque ligne de détails
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour valider la livraison et mettre à jour la ligne immédiatement
  void _validateDelivery(BuildContext context, Delivery delivery, int index) {
    final TextEditingController _codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Valider la livraison'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Code de validation'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (_codeController.text == delivery.validationCode) {
                  final success = await DeliveryService.updateDeliveryStatus(delivery.id, 'Terminé');
                  if (success) {
                    // Mise à jour immédiate de l'état
                    notifyListeners(); // Rafraîchir les données affichées
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Livraison validée avec succès')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la validation')));
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Code de validation incorrect')));
                }
              },
              child: Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour annuler la livraison et mettre à jour la ligne immédiatement
  void _cancelDelivery(BuildContext context, Delivery delivery, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir annuler cette livraison ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Non'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Oui'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await DeliveryService.updateDeliveryStatus(delivery.id, 'Annulé');
      if (success) {
        // Mise à jour immédiate de l'état
        notifyListeners(); // Rafraîchir les données affichées
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Livraison annulée avec succès')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'annulation')));
      }
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => deliveries.length;

  @override
  int get selectedRowCount => 0;
}
