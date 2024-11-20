import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  transfer,
  deposit,
  withdrawal
}

class TransactionModel {
  final String? id;
  final String? senderId;
  final String? receiverId;
  final double amount;
  final TransactionType type;
  final DateTime? timestamp;
  final String? description;

  TransactionModel({
    this.id,
    this.senderId,
    this.receiverId,
    required this.amount,
    required this.type,
    this.timestamp,
    this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      amount: (json['amount'] as num).toDouble(),
      type: _parseTransactionType(json['type']),
      timestamp: (json['timestamp'] as Timestamp?)?.toDate(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'timestamp': timestamp,
      'description': description,
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
        return TransactionType.transfer;
    }
  }
}