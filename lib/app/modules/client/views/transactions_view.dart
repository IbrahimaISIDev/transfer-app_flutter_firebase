import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';

class TransactionDetailView extends StatelessWidget {
  final TransactionModel transaction;
  final ClientTransactionController controller;

  const TransactionDetailView(
      {super.key, required this.transaction, required this.controller});

  bool _isTransactionCancellable() {
    if (transaction.timestamp == null) return false;

    final now = DateTime.now();
    final timeDifference = now.difference(transaction.timestamp!);

    return timeDifference.inMinutes <= 30 &&
        transaction.status.toLowerCase() != 'cancelled';
  }

  String _getTransactionTypeLabel() {
    switch (transaction.type) {
      case TransactionType.transfer:
        return 'Transfert';
      case TransactionType.deposit:
        return 'Dépôt';
      case TransactionType.withdrawal:
        return 'Retrait';
      case TransactionType.unlimit:
        return 'Transaction illimitée';
      default:
        return 'Transaction';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la ${_getTransactionTypeLabel()}'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Amount
            Text(
              'Montant: ${transaction.amount} F CFA',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 16),

            // Transaction Type
            Text('Type: ${_getTransactionTypeLabel()}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            // Sender Information
            Text(
              'Expéditeur: ${transaction.senderId ?? 'Non spécifié'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Receiver Information
            Text(
              'Destinataire: ${transaction.receiverId ?? 'Non spécifié'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Transaction Date
            Text(
              'Date: ${transaction.timestamp?.toLocal() ?? 'Date non disponible'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Transaction Status
            Text(
              'Statut: ${transaction.status.isEmpty ? 'En cours' : transaction.status}',
              style: TextStyle(
                  fontSize: 18,
                  color: transaction.status.toLowerCase() == 'cancelled'
                      ? Colors.red
                      : Colors.black),
            ),
            const SizedBox(height: 16),

            // Cancel Button
            if (_isTransactionCancellable())
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.defaultDialog(
                        title: 'Confirmer l\'annulation',
                        middleText:
                            'Voulez-vous vraiment annuler cette transaction ?',
                        textConfirm: 'Oui',
                        textCancel: 'Non',
                        onConfirm: () {
                          controller.cancelTransaction(transaction);
                          Get.back(); // Close dialog
                          Get.back(); // Close transaction detail view
                        });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Annuler la Transaction'),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
