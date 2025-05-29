import 'package:flutter/material.dart';
import 'buyer_signup/buyer_signup_page.dart'; // Import the Buyer Signup page // Import the Seller Signup page

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // Logo at the top of the screen
                  Image.asset(
                    'assets/images/PETWISE_LOGO.png', // Ensure the path is correct
                    height: 100, // Set a specific height for the logo
                  ),
                  SizedBox(height: 50),
                  // Buyer Signup Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Buyer Signup page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyerSignupPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE03E0B), // Button color
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: Text("Buyer Signup", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 20),
                  // Back to Login Button
                  TextButton(
                    onPressed: () {
                      // Navigate back to the Login page
                      Navigator.pop(context); // This pops the current SignupPage and returns to Login
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
