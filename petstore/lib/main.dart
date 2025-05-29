import 'package:flutter/material.dart';
import 'screens/home/home.dart'; // Import home.dart
import 'dart:async'; // Import Timer to create delay

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Set SplashScreen as the first screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay of 3 seconds to show the splash screen
    Timer(Duration(seconds: 3), () {
      // Navigate to Home screen after 3 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()), // Transition to Home screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF220F01), // Set background color
      body: Center(
        child: Image.asset(
          'assets/images/PETWISE_LOGO.png', // Image in assets/images
          width: 300, // Set the width of the logo
          height: 300, // Set the height of the logo
        ),
      ),
    );
  }
}
