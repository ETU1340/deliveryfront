import 'package:flutter/material.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';
import '../../models/manager.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // Pour les fichiers sur le Web7
import '../../services/manager_service.dart';

class LivreurDialog extends StatefulWidget {
  final String action; // 'create' ou 'update'
  final Livreur? livreur;
  final Function(Livreur) onSave;

  LivreurDialog({
    required this.action,
    this.livreur,
    required this.onSave,
  });

  @override
  _LivreurDialogState createState() => _LivreurDialogState();
}

class _LivreurDialogState extends State<LivreurDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _userNameController;
  late TextEditingController _nameController;
  late TextEditingController _firstNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  String? _selectedMoyenDeTransport;
  Uint8List? _webImage;
  String? _imageName; // Variable pour stocker le nom du fichier

  List<String> moyensDeTransport = [
    'Vélo',
    'Moto',
    'Voiture',
    'Camion',
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.livreur?.email ?? '');
    _userNameController = TextEditingController(text: widget.livreur?.userName ?? '');
    _nameController = TextEditingController(text: widget.livreur?.name ?? '');
    _firstNameController = TextEditingController(text: widget.livreur?.firstName ?? '');
    _addressController = TextEditingController(text: widget.livreur?.address ?? '');
    _phoneController = TextEditingController(text: widget.livreur?.phone ?? '');
    _selectedMoyenDeTransport = widget.livreur?.moyenDeTransport ?? moyensDeTransport.first;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _userNameController.dispose();
    _nameController.dispose();
    _firstNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() async {
        _webImage = await pickedFile.readAsBytes();
        _imageName = pickedFile.name; // Récupération du nom du fichier
      });
    }
  }

  Future<void> _saveLivreur(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      Manager? manager = await ManagerService.getManagerSession();

      final livreur = Livreur(
        id: widget.livreur?.id ?? '',
        email: _emailController.text,
        userName: _userNameController.text,
        name: _nameController.text,
        firstName: _firstNameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        currentLocation: manager?.location,
        moyenDeTransport: _selectedMoyenDeTransport!,
      );

      final success = widget.action == 'create'
          ? await LivreurService.createLivreur(livreur, _webImage, _imageName)
          : await LivreurService.updateLivreur(livreur, _webImage, _imageName);

      if (success) {
        widget.onSave(livreur);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.action == 'create' ? 'Livreur créé avec succès' : 'Livreur mis à jour avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur s\'est produite')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20),
      child: SizedBox(
        width: 600, // Largeur du modal ajustée
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.action == 'create' ? 'Ajouter un livreur' : 'Modifier le livreur',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _userNameController,
                        decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom d\'utilisateur';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Nom'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(labelText: 'Prénom'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un prénom';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(labelText: 'Adresse'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une adresse';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(labelText: 'Téléphone'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un numéro de téléphone';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedMoyenDeTransport,
                        decoration: InputDecoration(labelText: 'Moyen de Transport'),
                        items: moyensDeTransport.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedMoyenDeTransport = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un moyen de transport';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _webImage != null
                          ? Image.memory(_webImage!)
                          : Container(),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Sélectionner une image'),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _saveLivreur(context);
                            },
                            child: Text('Enregistrer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
