import 'package:flutter/material.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';

class LivreurDialog extends StatefulWidget {
  final Livreur? livreur;
  final Function(Livreur) onSave;

  LivreurDialog({this.livreur, required this.onSave});

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
  late TextEditingController _roleController;
  late TextEditingController _currentLocationController;
  late TextEditingController _unavailablePeriodsController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.livreur?.email ?? '');
    _userNameController = TextEditingController(text: widget.livreur?.name ?? '');
    _nameController = TextEditingController(text: widget.livreur?.name ?? '');
    _firstNameController = TextEditingController(text: widget.livreur?.name ?? '');
    _addressController = TextEditingController(text: widget.livreur?.address ?? '');
    _phoneController = TextEditingController(text: widget.livreur?.phone ?? '');
    _roleController = TextEditingController(text: widget.livreur?.role ?? 'Livreur');
    _currentLocationController = TextEditingController(
      text: widget.livreur != null
          ? '${widget.livreur!.currentLocation![0]}, ${widget.livreur!.currentLocation![1]}'
          : '',
    );
    _unavailablePeriodsController = TextEditingController(
      text: widget.livreur != null && widget.livreur!.unavailablePeriods != null
          ? widget.livreur!.unavailablePeriods!.map((p) => p.reason).join(', ')
          : '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _userNameController.dispose();
    _nameController.dispose();
    _firstNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _currentLocationController.dispose();
    _unavailablePeriodsController.dispose();
    super.dispose();
  }

  Future<void> createLivreur(BuildContext context) async {
   if (_formKey.currentState?.validate() ?? false) {
      final livreur = Livreur(
        id: widget.livreur?.id ?? '',
        email: _emailController.text,
        userName: _userNameController.text,
        name: _nameController.text,
        firstName: _firstNameController.text,
        address: _addressController.text,
        phone: _phoneController.text);
      final success = await LivreurService.createLivreur(livreur);
      if(success) {
         Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Livreur crée avec succés")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("une erreur ces produite")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.livreur == null ? 'Add Livreur' : 'Edit Livreur'),
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
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
               TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'Nom d`utilisateur'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter userName';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
               TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'firstName'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entré le prenom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone';
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
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
           createLivreur(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
