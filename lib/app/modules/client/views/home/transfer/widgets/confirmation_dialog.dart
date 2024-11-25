// Mise à jour de widgets/confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ConfirmationDialog extends StatelessWidget {
  final String amount;
  final String date;
  final String time;
  final String frequency;

  const ConfirmationDialog({
    super.key,
    required this.amount,
    required this.date,
    required this.time,
    required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4C6FFF),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Transfert programmé !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre transfert de $amount FCFA est programmé pour le $date à $time et sera répété $frequency',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C6FFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}