import 'package:flutter/material.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';
import './livreur_dialog.dart';
import './livreur_details_screen.dart';

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
      _filteredLivreurs = _livreurs
          .where((livreur) =>
              livreur.name.toLowerCase().contains(query.toLowerCase()) ||
              livreur.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterLivreurs,
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
                    DataColumn(label: Text('Actions')),
                  ],
                  source: _LivreurDataSource(
                    livreurs: _filteredLivreurs,
                    selectedLivreurs: _selectedLivreurs,
                    onDelete: _confirmDeleteLivreur,
                    onEdit: (livreur) => _createOrUpdateLivreur('update', livreur),
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
  final VoidCallback onSelectionChanged;

  _LivreurDataSource({
    required this.livreurs,
    required this.selectedLivreurs,
    required this.onDelete,
    required this.onEdit,
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
        DataCell(Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(livreur),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(livreur.id),
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
