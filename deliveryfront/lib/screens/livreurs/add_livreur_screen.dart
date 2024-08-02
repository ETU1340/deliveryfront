import 'package:flutter/material.dart';
import '../../services/livreur_service.dart';
import '../../models/livreur.dart';

class AddLivreurScreen extends StatefulWidget {
  final Livreur? livreur;

  AddLivreurScreen({this.livreur});
  @override
  _AddLivreurPageState createState() => _AddLivreurPageState();
}



class _AddLivreurPageState extends State<AddLivreurScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentLocationController = TextEditingController();

  final LivreurService _livreurService = LivreurService();

  @override
  void initState() {
    super.initState();
    if (widget.livreur != null) {
      _emailController.text = widget.livreur!.email;
      _passwordController.text = widget.livreur!.password;
      _nameController.text = widget.livreur!.name;
      _addressController.text = widget.livreur!.address;
      _phoneController.text = widget.livreur!.phone;
      _currentLocationController.text =
          widget.livreur!.currentLocation.join(',');
    }
  }

  Future<void> _addLivreur() async {
    if (_formKey.currentState?.validate() ?? false) {
     final livreur = Livreur(
        id: widget.livreur?.id ?? '',
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        role: 'Livreur',
        currentLocation:
          _currentLocationController.text.split(',').map(double.parse).toList(),
        unavailablePeriods: [], // Handle this appropriately
      );
      final response = await _livreurService.addLivreur(livreur);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Livreur added successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add livreur')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Livreur'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addLivreur,
                child: Text('Add Livreur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
