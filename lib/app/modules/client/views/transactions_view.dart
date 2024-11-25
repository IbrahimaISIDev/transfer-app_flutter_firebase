// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:money_transfer_app/app/data/models/transaction_model.dart';
// import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';

// class TransactionDetailView extends StatelessWidget {
//   final TransactionModel transaction;
//   final ClientTransactionController controller;

//   const TransactionDetailView(
//       {super.key, required this.transaction, required this.controller});

//   bool _isTransactionCancellable() {
//     if (transaction.timestamp == null) return false;

//     final now = DateTime.now();
//     final timeDifference = now.difference(transaction.timestamp!);

//     return timeDifference.inMinutes <= 30 &&
//         transaction.status.toLowerCase() != 'cancelled';
//   }

//   String _getTransactionTypeLabel() {
//     switch (transaction.type) {
//       case TransactionType.transfer:
//         return 'Transfert';
//       case TransactionType.deposit:
//         return 'Dépôt';
//       case TransactionType.withdrawal:
//         return 'Retrait';
//       case TransactionType.unlimit:
//         return 'Transaction illimitée';
//       default:
//         return 'Transaction';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Détails de la ${_getTransactionTypeLabel()}'),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Transaction Amount
//             Text(
//               'Montant: ${transaction.amount} F CFA',
//               style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green),
//             ),
//             const SizedBox(height: 16),

//             // Transaction Type
//             Text('Type: ${_getTransactionTypeLabel()}',
//                 style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 16),

//             // Sender Information
//             Text(
//               'Expéditeur: ${transaction.senderId ?? 'Non spécifié'}',
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 16),

//             // Receiver Information
//             Text(
//               'Destinataire: ${transaction.receiverId ?? 'Non spécifié'}',
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 16),

//             // Transaction Date
//             Text(
//               'Date: ${transaction.timestamp?.toLocal() ?? 'Date non disponible'}',
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 16),

//             // Transaction Status
//             Text(
//               'Statut: ${transaction.status.isEmpty ? 'En cours' : transaction.status}',
//               style: TextStyle(
//                   fontSize: 18,
//                   color: transaction.status.toLowerCase() == 'cancelled'
//                       ? Colors.red
//                       : Colors.black),
//             ),
//             const SizedBox(height: 16),

//             // Cancel Button
//             if (_isTransactionCancellable())
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Get.defaultDialog(
//                         title: 'Confirmer l\'annulation',
//                         middleText:
//                             'Voulez-vous vraiment annuler cette transaction ?',
//                         textConfirm: 'Oui',
//                         textCancel: 'Non',
//                         onConfirm: () {
//                           controller.cancelTransaction(transaction);
//                           Get.back(); // Close dialog
//                           Get.back(); // Close transaction detail view
//                         });
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Annuler la Transaction'),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';
import 'package:money_transfer_app/app/modules/client/controllers/transaction_controller.dart';

class TransactionListView extends StatelessWidget {
  final ClientTransactionController controller;
  final FirebaseService _firebaseService = FirebaseService();
  String getCurrentUserId() => _firebaseService.getCurrentUserId();

  TransactionListView({
    super.key,
    required this.controller,
    TransactionModel? transaction, // Make this optional
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchTransactions(),
        child: Obx(
          () => controller.transactions.isEmpty
              ? _buildEmptyState()
              : _buildTransactionsList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos transactions apparaîtront ici',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = controller.transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    bool isIncoming = transaction.receiverId == controller.getCurrentUserId();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => Get.to(() => TransactionListView(
              transaction: transaction,
              controller: controller,
            )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTransactionTypeIcon(transaction.type, isIncoming),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTransactionTypeLabel(
                              transaction.type, isIncoming),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(transaction.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncoming ? '+' : '-'} ${NumberFormat.currency(
                      symbol: 'FCFA ',
                      decimalDigits: 0,
                    ).format(transaction.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isIncoming ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (transaction.description?.isNotEmpty ?? false)
                Text(
                  transaction.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(transaction.status),
                  if (_isTransactionCancellable(transaction))
                    TextButton.icon(
                      onPressed: () => _showCancelConfirmation(transaction),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeIcon(TransactionType type, bool isIncoming) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case TransactionType.transfer:
        iconData = isIncoming ? Icons.call_received : Icons.call_made;
        iconColor = isIncoming ? Colors.green : Colors.red;
        break;
      case TransactionType.deposit:
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.green;
        break;
      case TransactionType.withdrawal:
        iconData = Icons.money_off;
        iconColor = Colors.red;
        break;
      case TransactionType.unlimit:
        iconData = Icons.all_inclusive;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.swap_horiz;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        label = 'Terminé';
        break;
      case 'pending':
        chipColor = Colors.orange;
        label = 'En attente';
        break;
      case 'cancelled':
        chipColor = Colors.red;
        label = 'Annulé';
        break;
      default:
        chipColor = Colors.grey;
        label = 'En cours';
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor.withOpacity(0.1),
    );
  }

  bool _isTransactionCancellable(TransactionModel transaction) {
    if (transaction.timestamp == null) return false;
    if (transaction.status.toLowerCase() == 'cancelled') return false;

    final now = DateTime.now();
    final timeDifference = now.difference(transaction.timestamp!);
    return timeDifference.inMinutes <= 30;
  }

  void _showCancelConfirmation(TransactionModel transaction) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmer l\'annulation'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette transaction ? Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelTransaction(transaction);
            },
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeLabel(TransactionType type, bool isIncoming) {
    switch (type) {
      case TransactionType.transfer:
        return isIncoming ? 'Transfert reçu' : 'Transfert envoyé';
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date inconnue';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Hier ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE HH:mm', 'fr_FR').format(date);
    } else {
      return DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(date);
    }
  }

  void _showFilterDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Filtrer les transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Toutes les transactions'),
              onTap: () {
                Get.back();
                controller.fetchTransactions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_made),
              title: const Text('Transferts'),
              onTap: () {
                Get.back();
                controller.fetchTransactionsByType(TransactionType.transfer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Dépôts'),
              onTap: () {
                Get.back();
                controller.fetchTransactionsByType(TransactionType.deposit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text('Retraits'),
              onTap: () {
                Get.back();
                controller.fetchTransactionsByType(TransactionType.withdrawal);
              },
            ),
          ],
        ),
      ),
    );
  }
}
