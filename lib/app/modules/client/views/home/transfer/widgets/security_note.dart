// widgets/security_note.dart
import 'package:flutter/material.dart';

class SecurityNote extends StatelessWidget {
  const SecurityNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF4C6FFF),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Le transfert sera automatiquement effectué à la date et l\'heure programmées',
              style: TextStyle(
                color: Color(0xFF2D3142),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}