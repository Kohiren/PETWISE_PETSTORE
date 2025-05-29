import 'package:flutter/material.dart';
import 'seller_signup_body.dart';

class SellerSignupPage extends StatelessWidget {
  const SellerSignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Signup'),
        backgroundColor: Color(0xFFE03E0B),
      ),
      body: SellerSignupBody(),
    );
  }
}
