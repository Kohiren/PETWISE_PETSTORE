import 'package:flutter/material.dart';

class SellerHome extends StatelessWidget {
  const SellerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seller Home")),
      body: Center(child: Text("Welcome Seller!")),
    );
  }
}