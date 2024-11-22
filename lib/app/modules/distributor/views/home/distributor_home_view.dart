import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/home_controller.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/operation_controller.dart';
import 'package:money_transfer_app/app/modules/distributor/views/home/widgets/balance_card_widget.dart';
import 'package:money_transfer_app/app/modules/distributor/views/home/widgets/operations_section.widget.dart';
import 'package:money_transfer_app/app/modules/distributor/views/home/widgets/transactions_section_widget.dart';
import 'package:money_transfer_app/app/routes/app_routes.dart';

class DistributorHomeView extends GetView<DistributorHomeController> {
  final DistributorOperationController operationController =
      Get.put(DistributorOperationController());

  @override
  Widget build(BuildContext context) {
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
                Obx(() => BalanceCard(
                      isBalanceVisible: controller.isBalanceVisible.value,
                      balance: controller.balance.value,
                      onToggleVisibility: controller.toggleBalanceVisibility,
                    )),
                const SizedBox(height: 24),
                OperationsSection(
                  operations: [
                    OperationButtonData(
                      icon: Icons.add_circle_outline,
                      title: 'Dépôt',
                      color: Colors.green,
                      onTap: () => Get.toNamed(AppRoutes.DISTRIBUTOR_DEPOSIT),
                    ),
                    OperationButtonData(
                      icon: Icons.remove_circle_outline,
                      title: 'Retrait',
                      color: Colors.orange,
                      onTap: () =>
                          Get.toNamed(AppRoutes.DISTRIBUTOR_WITHDRAWAL),
                    ),
                    OperationButtonData(
                      icon: Icons.upgrade,
                      title: 'Déplafond',
                      color: Colors.purple,
                      onTap: () =>
                          Get.toNamed(AppRoutes.DISTRIBUTOR_UNLIMIT_VIEW),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Obx(() => TransactionsSection(
                      transactions: controller.transactions,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
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
                // Redirection vers la page de connexion après la déconnexion
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}
