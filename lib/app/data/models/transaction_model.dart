import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  transfer,
  deposit,
  withdrawal,
  unlimit,
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
  final String status;
  final Map<String, String> metadata;

  TransactionModel({
    this.id,
    this.senderId,
    this.receiverId,
    required this.amount,
    required this.type,
    this.timestamp,
    this.description,
    this.scheduledDate,
    required this.status,
    required this.metadata,
  });

  // Factory pour construire un modèle à partir d'un JSON
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
      status: json['status'] as String? ?? '',
      metadata: Map<String, String>.from(json['metadata'] ?? {}),
    );
  }


  // Méthode pour convertir un modèle en JSON
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
      'status': status,
      'metadata': metadata,
    };
  }

  // Parse le type de transaction depuis une chaîne de caractères
  static TransactionType _parseTransactionType(String? typeString) {
    switch (typeString) {
      case 'transfer':
        return TransactionType.transfer;
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'unlimit':
        return TransactionType.unlimit;
      default:
        throw ArgumentError('Invalid transaction type: $typeString');
    }
  }
}
