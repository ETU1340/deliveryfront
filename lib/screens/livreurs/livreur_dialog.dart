import 'package:flutter/material.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';

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

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.livreur?.email ?? '');
    _userNameController = TextEditingController(text: widget.livreur?.userName ?? '');
    _nameController = TextEditingController(text: widget.livreur?.name ?? '');
    _firstNameController = TextEditingController(text: widget.livreur?.firstName ?? '');
    _addressController = TextEditingController(text: widget.livreur?.address ?? '');
    _phoneController = TextEditingController(text: widget.livreur?.phone ?? '');
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

  Future<void> _saveLivreur(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final livreur = Livreur(
        id: widget.livreur?.id ?? '',
        email: _emailController.text,
        userName: _userNameController.text,
        name: _nameController.text,
        firstName: _firstNameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        role: 'Livreur',
      );

      final success = widget.action == 'create'
          ? await LivreurService.createLivreur(livreur)
          : await LivreurService.updateLivreur(livreur);

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
    return AlertDialog(
      title: Text(widget.action == 'create' ? 'Ajouter un livreur' : 'Modifier le livreur'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            _saveLivreur(context);
          },
          child: Text('Enregistrer'),
        ),
      ],
    );
  }
}
