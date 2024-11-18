import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/operation_controller.dart';

class DistributorHomeView extends GetView<DistributorHomeController> {
  final DistributorOperationController operationController = 
    Get.put(DistributorOperationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Espace Distributeur'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => controller.logout(),
          )
        ],
      ),
      body: Column(
        children: [
          // Carte de solde
          Card(
            child: Obx(() => ListTile(
              title: Text('Solde'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.isBalanceVisible.value 
                    ? '${controller.balance.value} €' 
                    : '****'),
                  IconButton(
                    icon: Icon(controller.isBalanceVisible.value 
                      ? Icons.visibility 
                      : Icons.visibility_off),
                    onPressed: () => controller.toggleBalanceVisibility(),
                  )
                ],
              ),
            )),
          ),

          // Menu d'opérations
          ListTile(
            title: Text('Dépôt'),
            onTap: () => _showDepositDialog(),
          ),
          ListTile(
            title: Text('Retrait'),
            onTap: () => _showWithdrawalDialog(),
          ),

          // Liste des transactions
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.transactions.length,
              itemBuilder: (context, index) {
                var transaction = controller.transactions[index];
                return ListTile(
                  title: Text('Transaction ${transaction.type}'),
                  subtitle: Text('${transaction.amount} €'),
                  trailing: Text(transaction.timestamp.toString()),
                );
              },
            )),
          )
        ],
      ),
    );
  }

  void _showDepositDialog() {
    Get.defaultDialog(
      title: 'Effectuer un Dépôt',
      content: Column(
        children: [
          TextField(
            controller: operationController.phoneController,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 10),
          TextField(
            controller: operationController.amountController,
            decoration: InputDecoration(
              labelText: 'Montant',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      confirm: ElevatedButton(
        child: Text('Confirmer'),
        onPressed: () {
          operationController.performDeposit();
          Get.back(); // Fermer le dialog
        },
      ),
      cancel: TextButton(
        child: Text('Annuler'),
        onPressed: () => Get.back(),
      ),
    );
  }

  void _showWithdrawalDialog() {
    Get.defaultDialog(
      title: 'Effectuer un Retrait',
      content: Column(
        children: [
          TextField(
            controller: operationController.phoneController,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 10),
          TextField(
            controller: operationController.amountController,
            decoration: InputDecoration(
              labelText: 'Montant',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      confirm: ElevatedButton(
        child: Text('Confirmer'),
        onPressed: () {
          operationController.performWithdrawal();
          Get.back(); // Fermer le dialog
        },
      ),
      cancel: TextButton(
        child: Text('Annuler'),
        onPressed: () => Get.back(),
      ),
    );
  }
}