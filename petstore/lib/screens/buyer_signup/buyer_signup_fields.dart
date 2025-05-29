import 'package:flutter/material.dart';

Widget buildTextField(
  TextEditingController controller,
  String label, {
  bool obscure = false,
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator ?? (value) => value == null || value.isEmpty ? 'Required' : null,
    ),
  );
}
