import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';

class TransactionItemWidget extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItemWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _getTransactionColor(transaction.type).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          _getTransactionIcon(transaction.type),
          color: _getTransactionColor(transaction.type),
        ),
      ),
      title: Text(
        transaction.type.toString().split('.').last.capitalize ?? '',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        transaction.timestamp != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(transaction.timestamp!)
            : 'Date inconnue',
        style: GoogleFonts.poppins(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '${transaction.amount.toStringAsFixed(2)} F CFA',
        style: GoogleFonts.poppins(
          color: _getTransactionColor(transaction.type),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
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
}