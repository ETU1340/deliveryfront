import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';
import './livreur_dialog.dart';
import './livreur_details_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html; // Import nécessaire pour Flutter Web
import 'package:csv/csv.dart';
import 'dart:convert';
import '../../services/manager_service.dart';
import '../../models/manager.dart';
import 'progress_dialog_screen.dart';

class LivreursScreen extends StatefulWidget {
  @override
  _LivreursScreenState createState() => _LivreursScreenState();
}

class _LivreursScreenState extends State<LivreursScreen> {
  late Future<List<Livreur>> _livreursFuture;
  List<Livreur> _livreurs = [];
  List<Livreur> _filteredLivreurs = [];
  List<String> _selectedLivreurs = [];
  String _searchQuery = '';
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String? _selectedTransport;

  final List<String> _transports = [
    'Tous',
    'Voiture',
    'Moto',
    'Vélo',
    'Camion',
  ];

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
        _filteredLivreurs = livreurs;
        _selectedLivreurs.clear(); // Clear selection after loading
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du chargement des livreurs')),
      );
    }
  }

  void _showLivreurDetails(Livreur livreur) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LivreurDetailsModal(livreur: livreur);
      },
    );
  }

  void _createOrUpdateLivreur(String action, [Livreur? livreur]) {
    showDialog(
      context: context,
      builder: (context) => LivreurDialog(
        action: action,
        livreur: livreur,
        onSave: (savedLivreur) async {
          if (action == 'create') {
            setState(() {
              _livreurs.add(savedLivreur);
              _filteredLivreurs = _livreurs;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Livreur créé avec succès')),
            );
          } else {
            setState(() {
              final index = _livreurs.indexWhere((l) => l.id == savedLivreur.id);
              if (index != -1) {
                _livreurs[index] = savedLivreur;
                _filteredLivreurs = _livreurs;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Livreur mis à jour avec succès')),
            );
          }
          await _loadLivreurs();
        },
      ),
    );
  }

  void _importCsv() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files?.isEmpty ?? true) return;

      final file = files!.first;
      final reader = html.FileReader();

      reader.readAsText(file);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog();
        },
      );

      reader.onLoadEnd.listen((e) async {
        final csvContent = reader.result as String;
        final lines = const LineSplitter().convert(csvContent);
        final fields = lines.map((line) => line.split(',')).toList();
        Manager? manager = await ManagerService.getManagerSession();

        for (int i = 1; i < fields.length; i++) {
          final row = fields[i];

          final livreur = Livreur(
            id: '',
            email: row[0],
            userName: row[1],
            name: row[2],
            firstName: row[3],
            address: row[4],
            phone: row[5],
            moyenDeTransport: row[6],
            currentLocation: manager!.location,
          );

          await _uploadLivreur(livreur);
          ProgressDialog.updateProgress(i, fields.length - 1);
        }

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Importation CSV réussie')),
        );
        await _loadLivreurs();
      });
    });

    uploadInput.click();
  }

  Future<void> _uploadLivreur(Livreur livreur) async {
    try {
      await LivreurService.createLivreur(livreur, null, null);
    } catch (e) {
      print('Erreur lors de l\'importation: $e');
    }
  }

  Future<void> _confirmDeleteLivreur(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation de la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce livreur ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteLivreur(id);
    }
  }

  void _deleteLivreur(String id) async {
    try {
      await LivreurService.deleteLivreur(id);
      await _loadLivreurs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la suppression du livreur')),
      );
    }
  }

  void _filterLivreurs(String query) {
    setState(() {
      _searchQuery = query;
      _filteredLivreurs = _livreurs.where((livreur) {
        final matchNameOrEmail = livreur.name.toLowerCase().contains(query.toLowerCase()) ||
            livreur.email.toLowerCase().contains(query.toLowerCase());

        final matchTransport = _selectedTransport == null || _selectedTransport == 'Tous'
            ? true
            : livreur.moyenDeTransport == _selectedTransport;

        return matchNameOrEmail && matchTransport;
      }).toList();
    });
  }

  // Nouvelle fonction pour confirmer la suppression en masse
  Future<void> _confirmDeleteSelectedLivreurs() async {
    if (_selectedLivreurs.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation de la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer les livreurs sélectionnés ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteSelectedLivreurs();
    }
  }

  // Nouvelle fonction pour supprimer en masse
  Future<void> _deleteSelectedLivreurs() async {
    try {
      for (String id in _selectedLivreurs) {
        await LivreurService.deleteLivreur(id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Livreurs supprimés avec succès')),
      );
      await _loadLivreurs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la suppression des livreurs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livreurs'),
        actions: [
          // Afficher le bouton de suppression en masse uniquement si des livreurs sont sélectionnés
          if (_selectedLivreurs.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _confirmDeleteSelectedLivreurs,
              tooltip: 'Supprimer les sélectionnés',
            ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createOrUpdateLivreur('create'),
            tooltip: 'Ajouter un livreur',
          ),
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _importCsv,
            tooltip: 'Importer des livreurs depuis un CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres de recherche et de transport
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Rechercher',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filterLivreurs,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedTransport ?? 'Tous',
                    decoration: InputDecoration(
                      labelText: 'Transport',
                      border: OutlineInputBorder(),
                    ),
                    items: _transports.map((String transport) {
                      return DropdownMenuItem<String>(
                        value: transport,
                        child: Text(transport),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTransport = value;
                      });
                      _filterLivreurs(_searchQuery);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Liste des livreurs avec pagination
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: PaginatedDataTable(
                  header: Text('Liste des Livreurs'),
                  rowsPerPage: _rowsPerPage,
                  availableRowsPerPage: [5, 10, 20],
                  onRowsPerPageChanged: (value) {
                    setState(() {
                      _rowsPerPage = value ?? PaginatedDataTable.defaultRowsPerPage;
                    });
                  },
                  columns: [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Téléphone')),
                    DataColumn(label: Text('Transport')),
                    DataColumn(label: Text('Actions')),
                  ],
                  source: _LivreurDataSource(
                    livreurs: _filteredLivreurs,
                    selectedLivreurs: _selectedLivreurs,
                    onDelete: _confirmDeleteLivreur,
                    onEdit: (livreur) => _createOrUpdateLivreur('update', livreur),
                    onDetails: _showLivreurDetails,
                    onSelectionChanged: () {
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LivreurDataSource extends DataTableSource {
  final List<Livreur> livreurs;
  final List<String> selectedLivreurs;
  final void Function(String) onDelete;
  final void Function(Livreur) onEdit;
  final void Function(Livreur) onDetails;
  final VoidCallback onSelectionChanged;

  _LivreurDataSource({
    required this.livreurs,
    required this.selectedLivreurs,
    required this.onDelete,
    required this.onEdit,
    required this.onDetails,
    required this.onSelectionChanged,
  });

  @override
  DataRow getRow(int index) {
    final livreur = livreurs[index];
    final isSelected = selectedLivreurs.contains(livreur.id);

    return DataRow.byIndex(
      index: index,
      selected: isSelected,
      onSelectChanged: (selected) {
        if (selected == true) {
          selectedLivreurs.add(livreur.id);
        } else {
          selectedLivreurs.remove(livreur.id);
        }
        onSelectionChanged();
        notifyListeners();
      },
      cells: [
        DataCell(Text(livreur.name)),
        DataCell(Text(livreur.email)),
        DataCell(Text(livreur.phone)),
        DataCell(Text(livreur.moyenDeTransport)),
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.visibility, color: Colors.green),
              onPressed: () => onDetails(livreur),
              tooltip: 'Voir les détails',
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(livreur),
              tooltip: 'Modifier',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(livreur.id),
              tooltip: 'Supprimer',
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => livreurs.length;

  @override
  int get selectedRowCount => selectedLivreurs.length;
}
