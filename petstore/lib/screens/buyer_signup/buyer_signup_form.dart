import 'dart:io';
import 'package:flutter/material.dart';
import 'buyer_signup_controller.dart';
import 'buyer_signup_fields.dart';

class BuyerSignupForm extends StatefulWidget {
  final BuyerSignupController controller;

  const BuyerSignupForm({super.key, required this.controller});

  @override
  _BuyerSignupFormState createState() => _BuyerSignupFormState();
}

class _BuyerSignupFormState extends State<BuyerSignupForm> {
  File? selectedFile;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Form(
      key: c.formKey,
      child: Column(
        children: [
          buildTextField(c.firstName, "First Name", validator: c.validateMin6),
          buildTextField(c.middleName, "Middle Name", validator: c.validateMin6),
          buildTextField(c.lastName, "Last Name", validator: c.validateMin6),
          buildTextField(c.email, "Email", validator: c.validateEmail, keyboardType: TextInputType.emailAddress),
          buildTextField(c.password, "Password", obscure: true, validator: c.validatePassword),
          buildTextField(c.confirmPassword, "Confirm Password", obscure: true, validator: c.validateConfirmPassword),
          buildTextField(
            c.phone,
            "Phone",
            validator: c.validatePhone,
            keyboardType: TextInputType.number,
          ),
          buildTextField(c.province, "Province", validator: c.validateMin6),
          buildTextField(c.municipality, "Municipality", validator: c.validateMin6),
          buildTextField(c.barangay, "Barangay", validator: c.validateMin6),
          buildTextField(c.zipcode, "Zipcode", validator: c.validateMin6, keyboardType: TextInputType.number),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await c.pickValidId((file) {
                setState(() => selectedFile = file);
              });
            },
            icon: Icon(Icons.upload_file),
            label: Text(selectedFile == null ? "Upload Valid ID" : "ID Selected"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE03E0B),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              c.submitForm(context, () => Navigator.pop(context), selectedFile);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE03E0B),
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
