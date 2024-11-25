import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  transfer,
  deposit,
  withdrawal,
  unlimit,
}

enum TransferFrequency {
  once, // Pour les transferts uniques
  daily,
  weekly,
  monthly,
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
  final Map metadata;
  final double feeAmount;
  final bool userPaidFee;
  final double feePercentage;
  // Nouveaux champs pour la récurrence
  final TransferFrequency frequency;
  final DateTime? lastExecutionDate;
  final DateTime? nextExecutionDate;
  final int?
      executionsCount; // Nombre de fois que la transaction récurrente a été exécutée
  final bool isRecurring; // Indique si c'est une transaction récurrente

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
    this.metadata = const {},
    required this.feeAmount,
    required this.userPaidFee,
    required this.feePercentage,
    this.frequency = TransferFrequency.once,
    this.lastExecutionDate,
    this.nextExecutionDate,
    this.executionsCount,
    this.isRecurring = false,
  });

  // Factory pour construire un modèle à partir d'un JSON
  factory TransactionModel.fromJson(Map json) {
    return TransactionModel(
      id: json['id']?.toString(),
      senderId: json['senderId']?.toString(),
      receiverId: json['receiverId']?.toString(),
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      type: _parseTransactionType(json['type']),
      timestamp: _parseTimestamp(json['timestamp']),
      description: json['description']?.toString(),
      scheduledDate: _parseTimestamp(json['scheduledDate']),
      status: json['status']?.toString() ?? '',
      metadata: _parseMetadata(json['metadata']),
      feeAmount: json['feeAmount']?.toDouble() ?? 0.0,
      userPaidFee: _parseBoolValue(json['userPaidFee']),
      feePercentage: json['feePercentage']?.toDouble() ?? 0.0,
      frequency: _parseTransferFrequency(json['frequency']),
      lastExecutionDate: _parseTimestamp(json['lastExecutionDate']),
      nextExecutionDate: _parseTimestamp(json['nextExecutionDate']),
      executionsCount: json['executionsCount']?.toInt(),
      isRecurring: _parseBoolValue(json['isRecurring']),
    );
  }

  // Helper methods
  static bool _parseBoolValue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  static TransferFrequency _parseTransferFrequency(dynamic value) {
    if (value == null) return TransferFrequency.once;
    if (value is TransferFrequency) return value;

    switch (value.toString().toLowerCase()) {
      case 'daily':
        return TransferFrequency.daily;
      case 'weekly':
        return TransferFrequency.weekly;
      case 'monthly':
        return TransferFrequency.monthly;
      default:
        return TransferFrequency.once;
    }
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static TransactionType _parseTransactionType(dynamic value) {
    if (value == null) return TransactionType.transfer;
    if (value is TransactionType) return value;

    switch (value.toString().toLowerCase()) {
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'unlimit':
        return TransactionType.unlimit;
      default:
        return TransactionType.transfer;
    }
  }

  static Map _parseMetadata(dynamic value) {
    if (value == null) return {};
    if (value is Map) return value;
    return {};
  }

  static String _convertTransferFrequencyToString(TransferFrequency frequency) {
    switch (frequency) {
      case TransferFrequency.daily:
        return 'daily';
      case TransferFrequency.weekly:
        return 'weekly';
      case TransferFrequency.monthly:
        return 'monthly';
      default:
        return 'once';
    }
  }

  static String _convertTransactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'deposit';
      case TransactionType.withdrawal:
        return 'withdrawal';
      case TransactionType.unlimit:
        return 'unlimit';
      default:
        return 'transfer';
    }
  }

  // Méthode pour convertir un modèle en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': _convertTransactionTypeToString(type),
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'description': description,
      'scheduledDate':
          scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'status': status,
      'metadata': metadata,
      'feeAmount': feeAmount,
      'userPaidFee': userPaidFee,
      'feePercentage': feePercentage,
      'frequency': _convertTransferFrequencyToString(frequency),
      'lastExecutionDate': lastExecutionDate != null
          ? Timestamp.fromDate(lastExecutionDate!)
          : null,
      'nextExecutionDate': nextExecutionDate != null
          ? Timestamp.fromDate(nextExecutionDate!)
          : null,
      'executionsCount': executionsCount,
      'isRecurring': isRecurring,
    };
  }

  // Méthode pour calculer la prochaine date d'exécution
  DateTime calculateNextExecutionDate(DateTime fromDate) {
    switch (frequency) {
      case TransferFrequency.daily:
        return fromDate.add(const Duration(days: 1));
      case TransferFrequency.weekly:
        return fromDate.add(const Duration(days: 7));
      case TransferFrequency.monthly:
        // Ajoute un mois en tenant compte des différentes longueurs des mois
        int year = fromDate.year;
        int month = fromDate.month;
        int day = fromDate.day;

        month++;
        if (month > 12) {
          month = 1;
          year++;
        }

        // Gestion du dernier jour du mois
        int lastDayOfMonth = DateTime(year, month + 1, 0).day;
        if (day > lastDayOfMonth) {
          day = lastDayOfMonth;
        }

        return DateTime(
          year,
          month,
          day,
          fromDate.hour,
          fromDate.minute,
          fromDate.second,
        );
      default:
        return fromDate; // Pour TransferFrequency.once
    }
  }

  // Copier avec modifications
  TransactionModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    double? amount,
    TransactionType? type,
    DateTime? timestamp,
    String? description,
    DateTime? scheduledDate,
    String? status,
    Map? metadata,
    double? feeAmount,
    bool? userPaidFee,
    double? feePercentage,
    TransferFrequency? frequency,
    DateTime? lastExecutionDate,
    DateTime? nextExecutionDate,
    int? executionsCount,
    bool? isRecurring,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      feeAmount: feeAmount ?? this.feeAmount,
      userPaidFee: userPaidFee ?? this.userPaidFee,
      feePercentage: feePercentage ?? this.feePercentage,
      frequency: frequency ?? this.frequency,
      lastExecutionDate: lastExecutionDate ?? this.lastExecutionDate,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      executionsCount: executionsCount ?? this.executionsCount,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}

//  //Parse le type de transaction depuis une valeur dynamique
//   static TransactionType _parseTransactionType(dynamic typeValue) {
//     if (typeValue == null) return TransactionType.transfer;

//     String typeString = typeValue.toString().toLowerCase();
//     switch (typeString) {
//       case 'transfer':
//         return TransactionType.transfer;
//       case 'deposit':
//         return TransactionType.deposit;
//       case 'withdrawal':
//         return TransactionType.withdrawal;
//       case 'unlimit':
//         return TransactionType.unlimit;
//       default:
//         return TransactionType.transfer; // Valeur par défaut
//     }
//   }

//   // Convertit l'enum en chaîne de caractères de manière sécurisée
//   static String _convertTransactionTypeToString(TransactionType type) {
//     return type.toString().split('.').last;
//   }

//   // Méthode utilitaire pour parser les timestamps
//   static DateTime? _parseTimestamp(dynamic timestampValue) {
//     if (timestampValue == null) return null;

//     if (timestampValue is Timestamp) {
//       return timestampValue.toDate();
//     }

//     try {
//       return DateTime.parse(timestampValue.toString());
//     } catch (_) {
//       return null;
//     }
//   }

//   // Méthode utilitaire pour parser les métadonnées
//   static Map<String, dynamic> _parseMetadata(dynamic metadataValue) {
//     if (metadataValue == null) return {};

//     if (metadataValue is Map) {
//       return Map<String, dynamic>.from(metadataValue);
//     }

//     return {};
//   }

//   String getTypeString() {
//     return type.toString().split('.').last;
//   }