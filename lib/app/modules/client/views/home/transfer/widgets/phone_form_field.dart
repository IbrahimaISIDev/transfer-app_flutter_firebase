import 'package:flutter/material.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/modules/client/controllers/contact_controller.dart';
import 'contact_button.dart';

class PhoneFormField extends StatelessWidget {
  final TextEditingController controller;
  final ContactController contactController;
  final FavoritesProvider favoritesProvider;

  const PhoneFormField({
    super.key,
    required this.controller,
    required this.contactController,
    required this.favoritesProvider,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: 'Numéro de téléphone',
        prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF4C6FFF)),
        suffixIcon: ContactButton(
          phoneController: controller,
          contactController: contactController,
          favoritesProvider: favoritesProvider,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF4C6FFF),
            width: 2,
          ),
        ),
      ),
      validator: _validatePhone,
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro de téléphone requis';
    }
    if (!value.trim().replaceAll(RegExp(r'[^\d+]'), '').startsWith('+')) {
      return 'Format de numéro invalide';
    }
    return null;
  }
}