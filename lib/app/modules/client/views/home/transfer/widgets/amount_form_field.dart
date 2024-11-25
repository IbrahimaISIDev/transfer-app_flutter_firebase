import 'package:flutter/material.dart';

class AmountFormField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged; // Add onChanged parameter

  const AmountFormField({
    super.key,
    required this.controller,
    this.onChanged, // Initialize it in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Montant à envoyer',
        suffixText: 'FCFA',
        prefixIcon: const Icon(
          Icons.account_balance_wallet_outlined,
          color: Color(0xFF4C6FFF),
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
      validator: _validateAmount,
      onChanged: onChanged, // Pass it to the TextFormField
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Montant requis';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Montant invalide';
    }
    return null;
  }
}