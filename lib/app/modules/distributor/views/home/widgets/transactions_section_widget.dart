import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';

class TransactionsSection extends StatelessWidget {
  final RxList<TransactionModel> transactions;

  const TransactionsSection({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        Obx(() => _buildTransactionsList()),
      ],
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Transactions récentes',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(transactions[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune transaction récente',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final TransactionInfo info = _getTransactionInfo(transaction.type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildTransactionIcon(info),
        title: Text(
          info.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: _buildTransactionSubtitle(transaction),
        trailing: _buildTransactionAmount(transaction, info.color),
      ),
    );
  }

  Widget _buildTransactionIcon(TransactionInfo info) {
    return CircleAvatar(
      backgroundColor: info.color.withOpacity(0.9),
      child: Icon(
        info.icon,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTransactionSubtitle(TransactionModel transaction) {
    return Column(
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
            DateFormat('dd/MM/yyyy HH:mm').format(transaction.timestamp!),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionAmount(TransactionModel transaction, Color color) {
    final formattedAmount = NumberFormat.currency(
      symbol: 'F CFA',
      decimalDigits: 2,
      locale: 'fr_FR',
    ).format(transaction.amount);

    return Text(
      formattedAmount,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  TransactionInfo _getTransactionInfo(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return TransactionInfo(
          title: 'Dépôt',
          icon: Icons.add_circle_outline,
          color: Colors.green,
        );
      case TransactionType.withdrawal:
        return TransactionInfo(
          title: 'Retrait',
          icon: Icons.remove_circle_outline,
          color: Colors.orange,
        );
      default:
        return TransactionInfo(
          title: 'Transaction',
          icon: Icons.swap_horiz,
          color: Colors.blue,
        );
    }
  }
}

class TransactionInfo {
  final String title;
  final IconData icon;
  final Color color;

  const TransactionInfo({
    required this.title,
    required this.icon,
    required this.color,
  });
}