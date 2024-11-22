import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';

class TransferOptionsWidget extends StatelessWidget {
  const TransferOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transferts',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTransferButton(
                icon: Icons.send,
                label: 'Simple',
                color: Colors.blue,
                onTap: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_SIMPLE),
              ),
              _buildTransferButton(
                icon: Icons.group,
                label: 'Multiple',
                color: Colors.purple,
                onTap: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_MULTIPLE),
              ),
              _buildTransferButton(
                icon: Icons.schedule,
                label: 'Programmé',
                color: Colors.orange,
                onTap: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_SCHEDULED),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransferButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}