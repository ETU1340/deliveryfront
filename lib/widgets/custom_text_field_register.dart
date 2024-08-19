import 'package:flutter/material.dart';

class CustomTextFieldRegister extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData icon;
  final double width;
  final String? Function(String?)? validator;

  CustomTextFieldRegister({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.icon,
    this.width = 300.0, // Par défaut à 300.0 si non spécifié
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon, color: Colors.blue),
        ),
        validator: validator,
      ),
    );
  }
}
