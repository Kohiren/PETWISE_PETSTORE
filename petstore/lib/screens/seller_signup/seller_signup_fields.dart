import 'package:flutter/material.dart';

class SellerSignupFields extends StatelessWidget {
  final TextEditingController businessName;
  final TextEditingController firstname;
  final TextEditingController middlename;
  final TextEditingController lastname;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController conpas;
  final TextEditingController phone;
  final TextEditingController province;
  final TextEditingController municipality;
  final TextEditingController barangay;
  final TextEditingController zipcode;
  final String role;
  final bool isLoading;
  final VoidCallback onSignup;
  final VoidCallback onPickValidId;
  final VoidCallback onPickBusinessPermit;

  const SellerSignupFields({super.key, 
    required this.businessName,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.email,
    required this.password,
    required this.conpas,
    required this.phone,
    required this.province,
    required this.municipality,
    required this.barangay,
    required this.zipcode,
    required this.role,
    required this.isLoading,
    required this.onSignup,
    required this.onPickValidId,
    required this.onPickBusinessPermit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/PETWISE_LOGO.png', height: 100),
        SizedBox(height: 20),
        _buildTextField(businessName, 'Business Name'),
        _buildTextField(firstname, 'First Name'),
        _buildTextField(middlename, 'Middle Name'),
        _buildTextField(lastname, 'Last Name'),
        _buildTextField(email, 'Email'),
        _buildTextField(password, 'Password', obscure: true),
        _buildTextField(conpas, 'Confirm Password', obscure: true),
        _buildTextField(phone, 'Phone'),
        _buildTextField(province, 'Province'),
        _buildTextField(municipality, 'Municipality'),
        _buildTextField(barangay, 'Barangay'),
        _buildTextField(zipcode, 'Zipcode'),
        SizedBox(height: 10),
        ElevatedButton(onPressed: onPickValidId, child: Text("Upload Valid ID")),
        ElevatedButton(onPressed: onPickBusinessPermit, child: Text("Upload Business Permit")),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: isLoading ? null : onSignup,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFE03E0B),
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          labelStyle: TextStyle(color: Colors.white),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
