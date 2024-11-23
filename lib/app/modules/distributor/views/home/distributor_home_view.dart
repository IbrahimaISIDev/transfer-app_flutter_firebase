import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/home_controller.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/operation_controller.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';


class DistributorHomeView extends GetView<DistributorHomeController> {
  const DistributorHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(DistributorOperationController());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Espace Distributeur',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _showLogoutConfirmation(context),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await controller.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 24),
                _buildOperationsSection(),
                const SizedBox(height: 24),
                _buildTransactionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Solde disponible',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.isBalanceVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: controller.toggleBalanceVisibility,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                controller.isBalanceVisible.value
                    ? '${NumberFormat.currency(locale: 'fr_FR', symbol: 'F CFA').format(controller.balance.value)}'
                    : '• • • • • • • • • • • • • •',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildOperationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opérations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOperationButton(
                icon: Icons.add_circle_outline,
                title: 'Dépôt',
                color: Colors.green,
                onTap: () => Get.toNamed(AppRoutes.DISTRIBUTOR_DEPOSIT),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOperationButton(
                icon: Icons.remove_circle_outline,
                title: 'Retrait',
                color: Colors.orange,
                onTap: () => Get.toNamed(AppRoutes.DISTRIBUTOR_WITHDRAWAL),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOperationButton(
                icon: Icons.upgrade,
                title: 'Déplafond',
                color: Colors.purple,
                onTap: () => Get.toNamed(AppRoutes.DISTRIBUTOR_UNLIMIT_VIEW),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transactions récentes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            var transaction = controller.transactions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: _getTransactionColor(transaction.type),
                  child: Icon(
                    _getTransactionIcon(transaction.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  _getTransactionTitle(transaction.type),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (transaction.metadata['phoneNumber'] != null)
                      Text(
                        'N° : ${transaction.metadata['phoneNumber']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    if (transaction.timestamp != null)
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(transaction.timestamp!),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${transaction.amount.toStringAsFixed(2)} F CFA',
                      style: TextStyle(
                        color: _getTransactionColor(transaction.type),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ));
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.add_circle_outline;
      case TransactionType.withdrawal:
        return Icons.remove_circle_outline;
      default:
        return Icons.swap_horiz;
    }
  }

  String _getTransactionTitle(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Dépôt';
      case TransactionType.withdrawal:
        return 'Retrait';
      default:
        return 'Transaction';
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Déconnexion'),
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout();
                Get.offAllNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }
}