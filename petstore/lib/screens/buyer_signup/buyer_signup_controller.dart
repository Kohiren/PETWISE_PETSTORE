import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:petstore/api_endpoints.dart';



class BuyerSignupController {
  final formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final middleName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final phone = TextEditingController();
  final province = TextEditingController();
  final municipality = TextEditingController();
  final barangay = TextEditingController();
  final zipcode = TextEditingController();

  File? validIdFile;
  final ImagePicker picker = ImagePicker();

  // Validator: Require min 6 characters for all fields except phone and email
  String? validateMin6(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.trim().length < 6) {
      return 'Must be at least 6 characters';
    }
    return null;
  }

  // Email validator with required
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validator - min 6 chars and required
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm password validator - required and must match password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != password.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Phone validator - required, exactly 11 digits, numbers only
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\d{11}$'); // exactly 11 digits
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Phone number must be exactly 11 digits';
    }
    return null;
  }

  Future<void> pickValidId(Function(File) onPicked) async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onPicked(File(pickedFile.path));
    }
  }

  Future<void> submitForm(BuildContext context, VoidCallback onSuccess, File? file) async {
    if (formKey.currentState!.validate()) {
      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please upload a valid ID")),
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.signup),
      );

      request.fields['firstname'] = firstName.text.trim();
      request.fields['middlename'] = middleName.text.trim();
      request.fields['lastname'] = lastName.text.trim();
      request.fields['email'] = email.text.trim();
      request.fields['password'] = password.text;
      request.fields['conpas'] = confirmPassword.text;
      request.fields['phone'] = phone.text.trim();
      request.fields['province'] = province.text.trim();
      request.fields['municipality'] = municipality.text.trim();
      request.fields['barangay'] = barangay.text.trim();
      request.fields['zipcode'] = zipcode.text.trim();
      request.fields['role'] = 'buyer';

      String customFileName = '${firstName.text.trim()}.jpg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'valid_id',
          file.path,
          filename: customFileName,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup successful")),
        );
        onSuccess();
      } else {
        final res = await http.Response.fromStream(response);
        final msg = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg['message'] ?? 'Signup failed')),
        );
      }
    }
  }
}
