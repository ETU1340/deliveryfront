import 'package:flutter/material.dart';
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
  List<Livreur> _livreurs = [];
  String _searchQuery = '';
  String? _selectedType;
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
        bool matchesType = _selectedType == null || delivery.deliveryType == _selectedType;
        bool matchesStatus = _selectedStatus == null || delivery.status == _selectedStatus;
        bool matchesDate = _selectedDate == null || delivery.deliveryDateTime.toString().substring(0, 10) == _selectedDate.toString().substring(0, 10);

        return matchesSearchQuery && matchesType && matchesStatus  && matchesDate;
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
                      DataColumn(label: Text('Type de Livraison')),
                      DataColumn(label: Text('Statut')),
                      DataColumn(label: Text('Livreur')),
                      DataColumn(label: Text('Actions')),
                    ],
                    source: _DeliveryDataSource(
                      deliveries: _filteredDeliveries,
                      livreurs: _livreurs,
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
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type de Livraison',
                  border: OutlineInputBorder(),
                ),
                items: ['Urgent', 'Standard'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue;
                    _filterDeliveries();
                  });
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: ['Pending', 'In Progress', 'Completed', 'Cancelled'].map((String value) {
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
}

class _DeliveryDataSource extends DataTableSource {
  final List<Delivery> deliveries;
  final List<Livreur> livreurs;

  _DeliveryDataSource({required this.deliveries, required this.livreurs});

  @override
  DataRow getRow(int index) {
    final delivery = deliveries[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(delivery.clientName)),
        DataCell(Text(delivery.deliveryDateTime.toString().substring(0, 10))),
        DataCell(Text(delivery.deliveryType)),
        DataCell(Text(delivery.status)),
        DataCell(Text(delivery.livreur!.name)),
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Action pour éditer la livraison
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Action pour supprimer la livraison
              },
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => deliveries.length;

  @override
  int get selectedRowCount => 0;
}
