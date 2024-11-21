import 'package:flutter/material.dart';

/// Enumération des types d'utilisateurs.
enum UserType { client, distributor }

/// Modèle de données pour les utilisateurs.
class UserModel {
  final String? id; // ID unique de l'utilisateur (facultatif).
  final String email; // Email de l'utilisateur.
  final String phoneNumber; // Numéro de téléphone.
  final String? fullName; // Nom complet (facultatif).
  final String? agentCode; // Code agent (facultatif).
  final UserType userType; // Type d'utilisateur (client ou distributeur).
  double balance; // Solde de l'utilisateur.
  double monthlyTransactionLimit; // Limite mensuelle des transactions.

  /// Constructeur du modèle utilisateur.
  UserModel({
    this.id,
    required this.email,
    required this.phoneNumber,
    this.fullName,
    this.agentCode,
    required this.userType,
    this.balance = 0.0,
    this.monthlyTransactionLimit = 200000.0, // Valeur par défaut.
  });

  /// Vérifie si l'utilisateur peut déposer de l'argent.
  bool get canDeposit {
    return userType ==
        UserType.client; // Seuls les distributeurs peuvent déposer.
  }

  /// Vérifie si l'utilisateur peut retirer de l'argent.
  bool get canWithdraw {
    return userType ==
        UserType.client; // Seuls les distributeurs peuvent retirer.
  }

  /// Vérifie si l'utilisateur peut débloquer la limite de transactions.
  bool get canUnlimit {
    return userType ==
        UserType.client; // Seuls les distributeurs peuvent débloquer.
  }

  /// Conversion du modèle utilisateur en carte JSON pour Firestore.
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'agentCode': agentCode,
        'userType':
            userType.toString().split('.').last, // Convertir l'enum en chaîne.
        'balance': balance,
        'monthlyTransactionLimit':
            monthlyTransactionLimit, // Ajouté pour Firestore.
      };

  /// Création d'un utilisateur à partir d'une carte JSON (Firestore).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id']?.toString(),
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        fullName: json['fullName']?.toString(),
        agentCode: json['agentCode']?.toString(),
        userType: _parseUserType(json['userType']?.toString()),
        balance: (json['balance'] is num)
            ? (json['balance'] as num).toDouble()
            : double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
        monthlyTransactionLimit: (json['monthlyTransactionLimit'] is num)
            ? (json['monthlyTransactionLimit'] as num).toDouble()
            : double.tryParse(
                    json['monthlyTransactionLimit']?.toString() ?? '0') ??
                0.0,
      );
    } catch (e) {
      debugPrint('Erreur lors du parsing UserModel: $e');
      debugPrint('JSON reçu: $json');
      rethrow;
    }
  }

  /// Méthode privée pour analyser le type d'utilisateur.
  static UserType _parseUserType(String? type) {
    switch (type?.toLowerCase()) {
      case 'distributor':
        return UserType.distributor;
      case 'client':
        return UserType.client;
      default:
        return UserType.client; // Par défaut, on retourne 'client'.
    }
  }

  /// Surcharge de `toString` pour afficher les détails de l'utilisateur.
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, phoneNumber: $phoneNumber, '
        'fullName: $fullName, agentCode: $agentCode, userType: $userType, '
        'balance: $balance, monthlyTransactionLimit: $monthlyTransactionLimit)';
  }

  /// Création d'une copie du modèle avec des valeurs mises à jour.
  UserModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? fullName,
    String? agentCode,
    UserType? userType,
    double? balance,
    double? monthlyTransactionLimit,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      agentCode: agentCode ?? this.agentCode,
      userType: userType ?? this.userType,
      balance: balance ?? this.balance,
      monthlyTransactionLimit:
          monthlyTransactionLimit ?? this.monthlyTransactionLimit,
    );
  }
}
