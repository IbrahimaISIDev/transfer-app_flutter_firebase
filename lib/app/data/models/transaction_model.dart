import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  transfer,
  deposit,
  withdrawal,
}

class TransactionModel {
  final String? id;
  final String? senderId;
  final String? receiverId;
  final double amount;
  final TransactionType type;
  final DateTime? timestamp;
  final String? description;
  final DateTime? scheduledDate;

  TransactionModel({
    this.id,
    this.senderId,
    this.receiverId,
    required this.amount,
    required this.type,
    this.timestamp,
    this.description,
    this.scheduledDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String?,
      senderId: json['senderId'] as String?,
      receiverId: json['receiverId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: _parseTransactionType(json['type'] as String?),
      timestamp: (json['timestamp'] as Timestamp?)?.toDate(),
      description: json['description'] as String?,
      scheduledDate: (json['scheduledDate'] as Timestamp?)?.toDate(),
    );
  }

  get receiverPhone => null;

  get date => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'description': description,
      'scheduledDate':
          scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
    };
  }

  static TransactionType _parseTransactionType(String? typeString) {
    switch (typeString) {
      case 'transfer':
        return TransactionType.transfer;
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      default:
        throw ArgumentError('Invalid transaction type: $typeString');
    }
  }
}
