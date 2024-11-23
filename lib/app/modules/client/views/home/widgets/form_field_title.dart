import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/modules/client/controllers/contact_controller.dart';
import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';

// Widget pour le titre d'un champ de formulaire
class FormFieldTitle extends StatelessWidget {
  final String title;

  const FormFieldTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3142),
        ),
      ),
    );
  }
}