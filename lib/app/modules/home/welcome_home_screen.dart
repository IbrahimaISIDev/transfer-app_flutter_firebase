//modules/home/welcome_home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/core/utils/constants.dart';

// welcome_view.dart
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo et Titre
              const Icon(
                Icons.account_balance_wallet,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Money Transfer App',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Transférez de l\'argent facilement et en toute sécurité',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              // Boutons
              ElevatedButton(
                onPressed: () => Get.toNamed('/login'),
                style: AppStyles.elevatedButtonStyle,
                child: const Text(
                  'SE CONNECTER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Get.toNamed('/register'),
                style: AppStyles.outlinedButtonStyle,
                child: const Text(
                  'S\'INSCRIRE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}