import 'package:flutter/material.dart';
import '../widgets/custom_text_field_register.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import '../models/province.dart'; // Assurez-vous d'importer correctement la classe Province

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Province? _selectedProvince; // Variable pour stocker la province sélectionnée

  List<Province> provinces = [
    Province(name: "Antananarivo", latitude: -18.8792, longitude: 47.5079),
    Province(name: "Fianarantsoa", latitude: -21.4527, longitude: 47.0857),
    Province(name: "Toamasina", latitude: -18.1492, longitude: 49.4023),
    Province(name: "Mahajanga", latitude: -15.7167, longitude: 46.3167),
    Province(name: "Toliara", latitude: -23.35, longitude: 43.6667),
    Province(name: "Antsiranana", latitude: -12.2765, longitude: 49.2915),
  ];

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final userName = _userNameController.text;
      final password = _passwordController.text;
      final name = _nameController.text;
      final firstName = _firstNameController.text;
      final address = _addressController.text;
      final phone = _phoneController.text;
      final companyName = _companyNameController.text;

      if (_selectedProvince == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a province')),
        );
        return;
      }

      final result = await AuthService.register(
        email: email,
        userName: userName,
        password: password,
        name: name,
        firstName: firstName,
        address: address,
        phone: phone,
        companyName: companyName,
        province: _selectedProvince!.name,  
        longitude: _selectedProvince!.longitude, 
        latitude: _selectedProvince!.latitude,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );

        final success = await AuthService.login(
          userName,
          password,
        );
        if (success) {
          Navigator.pushNamed(context, '/home');
        }
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextFieldRegister(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextFieldRegister(
                          controller: _userNameController,
                          label: 'Nom d`utilisateur',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your userName';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextFieldRegister(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: true,
                          icon: Icons.lock,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextFieldRegister(
                          controller: _nameController,
                          label: 'Nom',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextFieldRegister(
                          controller: _firstNameController,
                          label: 'Prenom',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your firstName';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextFieldRegister(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.home,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextFieldRegister(
                          controller: _phoneController,
                          label: 'Telephone',
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                      SizedBox(height: 20),
                
                      CustomButton(
                        text: "S'inscrire",
                        onPressed: _register,
                      ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20), // Espacement entre les deux colonnes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Info du département',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: CustomTextFieldRegister(
                        controller: _companyNameController,
                        label: 'Nom de l\'entreprise',
                        icon: Icons.business,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the company name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: DropdownButtonFormField<Province>(
                        value: _selectedProvince,
                        decoration: InputDecoration(
                          labelText: 'Province',
                          border: OutlineInputBorder(),
                        ),
                        items: provinces.map((Province province) {
                          return DropdownMenuItem<Province>(
                            value: province,
                            child: Text(province.name),
                          );
                        }).toList(),
                        onChanged: (Province? newValue) {
                          setState(() {
                            _selectedProvince = newValue!;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a province' : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
