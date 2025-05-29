import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'seller_signup_fields.dart';
import 'seller_signup_service.dart';

class SellerSignupBody extends StatefulWidget {
  const SellerSignupBody({super.key});

  @override
  _SellerSignupBodyState createState() => _SellerSignupBodyState();
}

class _SellerSignupBodyState extends State<SellerSignupBody> {
  final TextEditingController businessName = TextEditingController();
  final TextEditingController firstname = TextEditingController();
  final TextEditingController middlename = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController conpas = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController municipality = TextEditingController();
  final TextEditingController barangay = TextEditingController();
  final TextEditingController zipcode = TextEditingController();
  final String role = 'seller';

  File? validIdFile;
  File? businessPermitFile;

  bool isLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _pickImage(Function(File) onSelected) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) onSelected(File(picked.path));
  }

  Future<void> _signup() async {
    if ([businessName, firstname, lastname, email, password, conpas, phone, province, municipality, barangay, zipcode]
        .any((controller) => controller.text.trim().isEmpty) ||
        validIdFile == null || businessPermitFile == null) {
      _showSnackBar("Please fill all fields and upload both files.");
      return;
    }

    setState(() => isLoading = true);

    final result = await SellerSignupService.signup(
      businessName: businessName.text.trim(),
      firstname: firstname.text.trim(),
      middlename: middlename.text.trim(),
      lastname: lastname.text.trim(),
      email: email.text.trim(),
      password: password.text.trim(),
      conpas: conpas.text.trim(),
      phone: phone.text.trim(),
      province: province.text.trim(),
      municipality: municipality.text.trim(),
      barangay: barangay.text.trim(),
      zipcode: zipcode.text.trim(),
      role: role,
      validIdFile: validIdFile!,
      businessPermitFile: businessPermitFile!,
    );

    setState(() => isLoading = false);

    if (result['success']) {
      _showSnackBar("Signup successful");
    } else {
      _showSnackBar(result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Color(0xFF220F01),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: SingleChildScrollView(
          child: SellerSignupFields(
            businessName: businessName,
            firstname: firstname,
            middlename: middlename,
            lastname: lastname,
            email: email,
            password: password,
            conpas: conpas,
            phone: phone,
            province: province,
            municipality: municipality,
            barangay: barangay,
            zipcode: zipcode,
            isLoading: isLoading,
            role: role,
            onSignup: _signup,
            onPickValidId: () => _pickImage((file) => setState(() => validIdFile = file)),
            onPickBusinessPermit: () => _pickImage((file) => setState(() => businessPermitFile = file)),
          ),
        ),
      ),
    );
  }
}
