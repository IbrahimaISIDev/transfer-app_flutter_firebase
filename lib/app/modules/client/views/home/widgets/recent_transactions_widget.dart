import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_transfer_app/app/modules/client/controllers/home_controller.dart';
import 'package:money_transfer_app/app/modules/client/views/home/widgets/transaction_item_widget.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final ClientHomeController controller;

  const RecentTransactionsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER_HISTORY),
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.poppins(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Obx(() {
            if (controller.recentTransactions.isEmpty) {
              return _buildEmptyTransactions();
            }
            return _buildTransactionsList();
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.history, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            'Aucune transaction récente',
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.recentTransactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = controller.recentTransactions[index];
        return TransactionItemWidget(transaction: transaction);
      },
    );
  }
}