enum TransactionType { 
  transfer, 
  deposit, 
  withdrawal, 
  scheduledTransfer 
}

class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final DateTime timestamp;
  final TransactionType type;
  final String? description;

  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.timestamp,
    required this.type,
    this.description
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'type': type.toString().split('.').last,
    'description': description
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'],
    senderId: json['senderId'],
    receiverId: json['receiverId'],
    amount: json['amount'],
    timestamp: DateTime.parse(json['timestamp']),
    type: TransactionType.values.firstWhere(
      (type) => type.toString().split('.').last == json['type']
    ),
    description: json['description']
  );
}