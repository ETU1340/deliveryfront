
import 'package:flutter/material.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';
import './livreur_dialog.dart';
import './livreur_details_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html; // Import nécessaire pour Flutter Web
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
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
  String? _selectedTransport; // Filtre par moyen de transport

   final List<String> _transports = [
    'Tous',
    'Voiture',
    'Moto',
    'Vélo',
    'Camion',
  ]; // Exemple de moyens de transport



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
  // Crée un élément input de type fichier
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.accept = '.csv'; // Limite le type de fichier à .csv

  uploadInput.onChange.listen((e) async {
    final files = uploadInput.files;
    if (files?.isEmpty ?? true) return;

    final file = files!.first;
    final reader = html.FileReader();

    reader.readAsText(file);

    // Afficher le dialogue de progression
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture du dialogue en cliquant à l'extérieur
      builder: (BuildContext context) {
        return ProgressDialog(); // Widget customisé pour afficher la progression
      },
    );

    reader.onLoadEnd.listen((e) async {
      final csvContent = reader.result as String;

      // Traitement des données CSV
      final lines = const LineSplitter().convert(csvContent);
      final fields = lines.map((line) => line.split(',')).toList();

      Manager? manager = await ManagerService.getManagerSession();

      // Ignorer la première ligne (en-têtes de colonne)
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];

        final livreur = Livreur(
          id: '', // ID sera généré par le backend
          email: row[0],
          userName: row[1],
          name: row[2],
          firstName: row[3],
          address: row[4],
          phone: row[5],
          moyenDeTransport: row[6],
          currentLocation: manager!.location, // Configurez ceci si nécessaire
        );

        // Envoyer chaque livreur au backend
        await _uploadLivreur(livreur);

        // Mettre à jour la progression dans le dialogue
        ProgressDialog.updateProgress(i, fields.length - 1);
      }

      // Fermer le dialogue de progression après l'importation
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Importation CSV réussie')),
      );
      await _loadLivreurs();
    });
  });

  // Déclenche le clic pour ouvrir le sélecteur de fichiers
  uploadInput.click();
}


  // Fonction pour envoyer les données du livreur au backend
  Future<void> _uploadLivreur(Livreur livreur) async {
    try {
        await LivreurService.createLivreur(livreur,null,null);

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

   void _filterByTransport(String? transport) {
    setState(() {
      _selectedTransport = transport;
      _filterLivreurs(_searchQuery);
    });
  }

  Future<void> _confirmDeleteSelectedLivreurs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation de la suppression en masse'),
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
      _deleteSelectedLivreurs();
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

  void _deleteSelectedLivreurs() async {
    try {
      for (var id in _selectedLivreurs) {
        await LivreurService.deleteLivreur(id);
      }
      setState(() {
        _selectedLivreurs.clear();
      });
      await _loadLivreurs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la suppression des livreurs sélectionnés')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livreurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createOrUpdateLivreur('create'),
          ),
          if (_selectedLivreurs.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _confirmDeleteSelectedLivreurs,
            ),
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _importCsv, // Ajouter le bouton pour importer CSV
          ),
        ],
      ),
      body: Column(
        children: [
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
                    onChanged: _filterByTransport,
                  ),
                ),
              ],
            ),
          ),
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
                    onDetails: (livreur) =>_showLivreurDetails(livreur),
                    onSelectionChanged: () {
                      setState(() {
                        // Met à jour l'interface pour afficher le bouton de suppression en masse
                      });
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
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(livreur),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(livreur.id),
            )
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
