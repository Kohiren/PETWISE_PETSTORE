import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petstore/api_endpoints.dart';

import 'signup.dart';
import 'buyer_home/buyer_home.dart';
import 'forgot_password.dart';
import 'courier_home.dart'; // Make sure this is correctly linked


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('province', user['province'] ?? '');
    await prefs.setString('municipality', user['municipality'] ?? '');
    await prefs.setString('barangay', user['barangay'] ?? '');
    await prefs.setString('zipcode', user['zipcode'] ?? '');
  }

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showDialog("Missing Fields", "Please enter both username and password", isSuccess: false);
      return;
    }

    var data = {
      'email': username,
      'password': password,
    };

    var url = Uri.parse(ApiEndpoints.login);
    
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['message'] == "Login successful") {
        var user = responseData['user'];

        _showDialog("Success", "Login successful!", isSuccess: true);

        await _saveUserInfo(user);
        await Future.delayed(Duration(seconds: 2));
        Navigator.of(context).pop(); // Close dialog

        if (user['role'] == 'buyer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BuyerHome(
                name: user['firstname'],
                email: user['email'],
                phone: user['phone'],
                address: "${user['barangay']}, ${user['municipality']}, ${user['province']} ${user['zipcode']}",
              ),
            ),
          );
        } else if (user['role'] == 'rider') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CourierScreen()),
          );
        }
      } else {
        _showDialog("Login Failed", "Invalid email or password", isSuccess: false);
      }
    } else {
      _showDialog("Server Error", "Something went wrong. Please try again.", isSuccess: false);
    }
  }

  void _showDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: !isSuccess,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2C1A10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.greenAccent : Colors.redAccent,
              ),
              SizedBox(width: 10),
              Text(title, style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(message, style: TextStyle(color: Colors.white70)),
          actions: [
            if (!isSuccess)
              TextButton(
                child: Text("OK", style: TextStyle(color: Color(0xFFE03E0B))),
                onPressed: () => Navigator.of(context).pop(),
              )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFF220F01),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/PETWISE_LOGO.png', height: 100),
                  SizedBox(height: 50),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text("Forgot Password?", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE03E0B),
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  SizedBox(height: 1),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: Text("Don't have an account? Sign up", style: TextStyle(color: Colors.white)),
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
