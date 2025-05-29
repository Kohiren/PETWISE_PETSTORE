import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword() {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your email address"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      // Here, you would typically handle the password reset process
      // For now, we show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset instructions sent to $email"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      // You can add navigation back to login screen after the password reset process
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
        backgroundColor: Color(0xFF220F01), // Dark background color
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFF220F01), // Dark background color
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo at the top of the container
                  Image.asset(
                    'assets/images/PETWISE_LOGO.png', // Make sure this path matches your image location
                    height: 100, // Set a specific height for the logo
                  ),
                  SizedBox(height: 50),
                  // Email Field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Enter your email address',
                      labelStyle: TextStyle(color: Colors.white), // White label color
                      prefixIcon: Icon(Icons.email, color: Colors.white), // White icon color
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3), // Transparent input field background
                    ),
                    style: TextStyle(color: Colors.white), // White text color
                  ),
                  SizedBox(height: 20),
                  // Reset Button
                  ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE03E0B), // Button color
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: Text("Reset Password", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  SizedBox(height: 20),
                  // Go back to Login page
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous page (Login)
                    },
                    child: Text(
                      "Back to Login",
                      style: TextStyle(color: Colors.white), // White text color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
