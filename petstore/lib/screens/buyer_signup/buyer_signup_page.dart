import 'package:flutter/material.dart';
import 'buyer_signup_controller.dart';
import 'buyer_signup_form.dart';

class BuyerSignupPage extends StatelessWidget {
  const BuyerSignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = BuyerSignupController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Signup'),
        backgroundColor: const Color(0xFFE03E0B),
      ),
      backgroundColor: const Color(0xFF220F01),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/images/PETWISE_LOGO.png', height: 100),
            const SizedBox(height: 20),
            BuyerSignupForm(controller: controller),
          ],
        ),
      ),
    );
  }
}
