import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/modules/client/views/transactions_view.dart';
import '../controllers/transaction_controller.dart';

class TransactionHistoryView extends GetView<ClientTransactionController> {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Transactions'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          // Assurez-vous que vous avez une variable observable pour l'historique des transactions
          if (controller.transactions.isEmpty) {
            return const Center(
              child: Text('Aucune transaction effectuée.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }
          return ListView.builder(
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              final transaction = controller.transactions[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: Icon(
                    Icons.payment,
                    color: Colors.blue.shade600,
                    size: 40,
                  ),
                  title: Text(
                    'Montant: ${transaction.amount} F CFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Destinataire: ${transaction.receiverId}'),
                      Text('Date: ${transaction.timestamp}'),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: Colors.blue.shade600,
                  ),
                  onTap: () {
                    Get.to(() => TransactionListView(
                          transaction: transaction,
                          controller: controller,
                        ));
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

