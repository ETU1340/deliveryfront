import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;

  CustomTextField({required this.controller, required this.label, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
     return Container(
      width: 250,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
     );
  }
}
