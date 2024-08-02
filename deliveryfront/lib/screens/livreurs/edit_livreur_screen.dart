import 'package:flutter/material.dart';
import '../../services/livreur_service.dart'; // Assurez-vous que ce fichier existe
import '../../models/livreur.dart';
class EditLivreurScreen extends StatefulWidget {
  final Livreur? livreur;

  EditLivreurScreen({required this.livreur});

  @override
  _EditLivreurPageState createState() => _EditLivreurPageState();
}

class _EditLivreurPageState extends State<EditLivreurScreen> {


  final LivreurService _livreurService = LivreurService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
      if (widget.livreur != null) {
      _emailController.text = widget.livreur!.email;
      _nameController.text = widget.livreur!.name;
      _addressController.text = widget.livreur!.address;
      _phoneController.text = widget.livreur!.phone;
      _currentLocationController.text = widget.livreur!.currentLocation.coordinates.join(', ');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final livreur = Livreur(
        id: widget.livreur?.id,
        email: _emailController.text,
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        role: 'Livreur',
        currentLocation: CurrentLocation(
          coordinates: _currentLocationController.text.split(', ').map((e) => double.parse(e)).toList(),
        ),
        unavailablePeriods: widget.livreur?.unavailablePeriods ?? [],
      );

      if (widget.livreur == null) {
        await _livreurService.addLivreur(livreur);
      } else {
        await _livreurService.updateLivreur(livreur.id!, livreur);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.livreur == null ? 'Add Livreur' : 'Edit Livreur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                // Name
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
                SizedBox(height: 10),
                // Address
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
                SizedBox(height: 10),
                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                // Current Location
                TextFormField(
                  controller: _currentLocationController,
                  decoration: InputDecoration(labelText: 'Current Location (lat, long)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current location';
                    }
                    if (!RegExp(r'^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$').hasMatch(value)) {
                      return 'Please enter a valid location (lat, long)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(widget.livreur == null ? 'Add' : 'Update'),
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