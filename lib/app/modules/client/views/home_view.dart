import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:money_transfer_app/app/modules/client/controllers/home_controller.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';
import 'package:money_transfer_app/core/utils/colors.dart';

class ClientHomeView extends GetView<ClientHomeController> {
  const ClientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildBalanceSection(),
              _buildQuickActionsSection(),
              _buildRecentTransactionsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
        floating: true,
        pinned: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(() => Text(
              'Bonjour, ${controller.currentUser.value?.fullName ?? "Client"}',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () {
              // Utiliser AuthController pour gérer la déconnexion
              final authController = Get.find<AuthController>();
              authController.logout();

              // Rediriger vers la page de connexion et effacer la pile de navigation
              Get.offAllNamed(AppRoutes.LOGIN);
            },
          ),
        ]);
  }

  SliverToBoxAdapter _buildBalanceSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solde Total',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Obx(() => IconButton(
                          icon: Icon(
                            controller.isBalanceVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: controller.toggleBalanceVisibility,
                        ))
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() => Text(
                      controller.isBalanceVisible.value
                          ? '${controller.balance.value.toStringAsFixed(2)} €'
                          : '******',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildQuickActionsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions Rapides',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickActionButton(
                    icon: Icons.send,
                    label: 'Transfert',
                    onTap: () => Get.toNamed(AppRoutes.CLIENT_TRANSFER),
                  ),
                  _quickActionButton(
                    icon: Icons.swap_horiz,
                    label: 'Historique',
                    onTap: () => Get.toNamed(AppRoutes.CLIENT_TRANSACTIONS),
                  ),
                  // _quickActionButton(
                  //   icon: Icons.add,
                  //   label: 'Dépôt',
                  //   onTap: () => Get.toNamed(AppRoutes.CLIENT_DEPOSIT),
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRecentTransactionsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dernières Transactions',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.CLIENT_TRANSACTIONS),
                  child: const Text('Voir Tout'),
                )
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.recentTransactions.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune transaction récente',
                    style: GoogleFonts.poppins(),
                  ),
                );
              }
              return Column(
                children: controller.recentTransactions
                    .map(
                        (transaction) => _buildTransactionListTile(transaction))
                    .toList(),
              );
            })
          ],
        ),
      ),
    );
  }

  ListTile _buildTransactionListTile(TransactionModel transaction) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTransactionColor(transaction.type),
        child: Icon(_getTransactionIcon(transaction.type)),
      ),
      title: Text(
        transaction.type.toString().split('.').last.capitalize ?? '',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        transaction.timestamp != null
            ? _formatTransactionDate(transaction.timestamp!)
            : 'Date inconnue',
        style: GoogleFonts.poppins(color: Colors.grey),
      ),
      trailing: Text(
        '${transaction.amount.toStringAsFixed(2)} €',
        style: TextStyle(
          color: _getTransactionColor(transaction.type),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  CurvedNavigationBar _buildBottomNavigationBar() {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: AppColors.primary,
      items: const [
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.swap_horiz, size: 30, color: Colors.white),
        Icon(Icons.add_circle_outline, size: 30, color: Colors.white),
        Icon(Icons.settings, size: 30, color: Colors.white),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Home
            break;
          case 1:
            Get.toNamed(AppRoutes.CLIENT_TRANSACTIONS);
            break;
          case 2:
            //Get.toNamed(AppRoutes.CLIENT_DEPOSIT);
            break;
          case 3:
            //Get.toNamed(AppRoutes.CLIENT_SETTINGS);
            break;
        }
      },
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return Icons.send;
      case TransactionType.deposit:
        return Icons.add;
      case TransactionType.withdrawal:
        return Icons.remove;
      default:
        return Icons.swap_horiz;
    }
  }

  String _formatTransactionDate(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }
}
