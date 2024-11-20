import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import '../controllers/transaction_controller.dart';


class ClientTransactionsView extends GetView<ClientTransactionController> {
  const ClientTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Transactions')),
      body: Obx(() => ListView.builder(
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              var transaction = controller.transactions[index];
              return ListTile(
                title: Text(transaction.type.toString().split('.').last),
                subtitle: Text(transaction.timestamp.toString()),
                trailing: Text('${transaction.amount} F CFA'),
                leading: _getTransactionIcon(transaction.type),
              );
            },
          )),
    );
  }

  Widget _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return const Icon(Icons.send, color: Colors.blue);
      case TransactionType.deposit:
        return const Icon(Icons.add, color: Colors.green);
      case TransactionType.withdrawal:
        return const Icon(Icons.remove, color: Colors.red);
      default:
        return const Icon(Icons.attach_money,
            color: Colors.grey); // Use a valid icon
    }
  }
}
