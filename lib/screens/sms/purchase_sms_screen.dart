import 'package:flutter/material.dart';

class PurchaseSmsLoadingScreen extends StatelessWidget {
  const PurchaseSmsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF3B3FE0), Color(0xFF7B2FA0), Color(0xFFE0333B)],
          ),
        ),
        child: const SafeArea(
          child: Center(
            child: Text(
              'Purchase SMS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}