import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Constant fee percentage (configurable)
  static const double BASE_FEE_PERCENTAGE = 0.02; // 2% fee
  // Calculate transfer fee
  double calculateTransferFee(double amount, {bool useFixedFee = false}) {
    if (useFixedFee) {
      // Option for a fixed fee structure
      return amount * BASE_FEE_PERCENTAGE;
    }

    // Progressive fee structure
    if (amount <= 1000) return 50; // Flat fee for small transfers
    if (amount <= 5000) return amount * 0.015; // 1.5% for medium transfers
    if (amount <= 10000) return amount * 0.02; // 2% for larger transfers
    return amount * 0.025; // 2.5% for very large transfers
  }

  // Calculate receivable amount based on fee option
  Map<String, double> calculateTransferAmounts(double amount,
      {bool userPaidFee = false}) {
    double feeAmount = calculateTransferFee(amount);

    return {
      'totalAmount': userPaidFee ? amount + feeAmount : amount,
      'receivableAmount': userPaidFee ? amount : amount - feeAmount,
      'feeAmount': feeAmount
    };
  }

  // Créer une nouvelle transaction
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      print('Erreur de création de transaction : $e');
      rethrow;
    }
  }

  // Récupérer toutes les transactions d'un utilisateur (envoyées et reçues)
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    try {
      // Récupérer les transactions envoyées
      var sentQuery = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      // Récupérer les transactions reçues
      var receivedQuery = await _firestore
          .collection('transactions')
          .where('receiverId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      // Combiner et trier toutes les transactions
      List<TransactionModel> allTransactions = [
        ...sentQuery.docs.map((doc) => TransactionModel.fromJson(doc.data())),
        ...receivedQuery.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
      ];

      // Trier par date (plus récent au plus ancien)
      allTransactions.sort((a, b) {
        if (a.timestamp == null || b.timestamp == null) return 0;
        return b.timestamp!.compareTo(a.timestamp!);
      });

      return allTransactions;
    } catch (e) {
      print('Erreur de récupération des transactions : $e');
      rethrow;
    }
  }

  // Récupérer les transactions par type
  Future<List<TransactionModel>> getUserTransactionsByType(
      String userId, TransactionType type) async {
    try {
      // Récupérer les transactions envoyées du type spécifié
      var sentQuery = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: userId)
          .where('type', isEqualTo: _convertTransactionTypeToString(type))
          .orderBy('timestamp', descending: true)
          .get();

      // Récupérer les transactions reçues du type spécifié
      var receivedQuery = await _firestore
          .collection('transactions')
          .where('receiverId', isEqualTo: userId)
          .where('type', isEqualTo: _convertTransactionTypeToString(type))
          .orderBy('timestamp', descending: true)
          .get();

      List<TransactionModel> typeTransactions = [
        ...sentQuery.docs.map((doc) => TransactionModel.fromJson(doc.data())),
        ...receivedQuery.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
      ];

      typeTransactions.sort((a, b) {
        if (a.timestamp == null || b.timestamp == null) return 0;
        return b.timestamp!.compareTo(a.timestamp!);
      });

      return typeTransactions;
    } catch (e) {
      print('Erreur de récupération des transactions par type : $e');
      rethrow;
    }
  }

  // Créer une transaction programmée
  Future<void> createScheduledTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('scheduled_transactions')
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      print('Erreur de création de transaction programmée : $e');
      rethrow;
    }
  }

  // Récupérer les transactions programmées
  Future<List<TransactionModel>> getScheduledTransactions(String userId) async {
    try {
      var querySnapshot = await _firestore
          .collection('scheduled_transactions')
          .where('senderId', isEqualTo: userId)
          .orderBy('scheduledDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur de récupération des transactions programmées : $e');
      rethrow;
    }
  }

  // Traiter les transactions programmées
  Future<void> processScheduledTransactions() async {
    try {
      var now = DateTime.now();
      var scheduledTransactions = await _firestore
          .collection('scheduled_transactions')
          .where('scheduledDate', isLessThanOrEqualTo: now)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in scheduledTransactions.docs) {
        var transaction = TransactionModel.fromJson(doc.data());

        // Exécuter la transaction dans une transaction Firestore
        await _firestore.runTransaction((TransactionFirebase) async {
          // Vérifier le solde de l'expéditeur
          var senderDoc = await TransactionFirebase.get(
              _firestore.collection('users').doc(transaction.senderId));

          double senderBalance =
              (senderDoc.data()?['balance'] ?? 0.0) as double;

          if (senderBalance >= transaction.amount) {
            // Mettre à jour les soldes
            TransactionFirebase.update(
                _firestore.collection('users').doc(transaction.senderId),
                {'balance': FieldValue.increment(-transaction.amount)});

            TransactionFirebase.update(
                _firestore.collection('users').doc(transaction.receiverId),
                {'balance': FieldValue.increment(transaction.amount)});

            // Créer la transaction réelle
            TransactionFirebase.set(
                _firestore.collection('transactions').doc(transaction.id),
                transaction.toJson());

            // Marquer la transaction programmée comme complétée
            TransactionFirebase.update(
                _firestore
                    .collection('scheduled_transactions')
                    .doc(transaction.id),
                {'status': 'completed'});
          } else {
            // Marquer la transaction comme échouée si le solde est insuffisant
            TransactionFirebase.update(
                _firestore
                    .collection('scheduled_transactions')
                    .doc(transaction.id),
                {'status': 'failed', 'failureReason': 'Solde insuffisant'});
          }
        });
      }
    } catch (e) {
      print('Erreur lors du traitement des transactions programmées : $e');
      rethrow;
    }
  }

  // Récupérer les transactions par type pour un distributeur
  Future<List<TransactionModel>> getTransactionsByType({
    required TransactionType type,
    required DateTime startDate,
    required DateTime endDate,
    required String distributorId,
  }) async {
    try {
      var querySnapshot = await _firestore
          .collection('transactions')
          .where('type', isEqualTo: _convertTransactionTypeToString(type))
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('metadata.distributorId', isEqualTo: distributorId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des transactions par type : $e');
      rethrow;
    }
  }

  // Annuler une transaction
// Méthode mise à jour pour annuler une transaction
  Future<void> cancelTransaction(String transactionId) async {
    try {
      await _firestore.runTransaction((TransactionFirebase) async {
        // Récupérer la transaction
        DocumentSnapshot transactionDoc = await TransactionFirebase.get(
            _firestore.collection('transactions').doc(transactionId));

        if (!transactionDoc.exists) {
          throw Exception('Transaction non trouvée');
        }

        Map<String, dynamic> transactionData =
            transactionDoc.data() as Map<String, dynamic>;

        // Vérifier explicitement si les champs requis existent
        if (!transactionData.containsKey('type') ||
            !transactionData.containsKey('timestamp') ||
            !transactionData.containsKey('amount') ||
            !transactionData.containsKey('senderId') ||
            !transactionData.containsKey('receiverId')) {
          throw Exception('Données de transaction invalides');
        }

        var transaction = TransactionModel.fromJson(transactionData);

        // Vérifier si la transaction peut être annulée (moins de 30 minutes)
        if (transaction.timestamp != null) {
          var timeDifference =
              DateTime.now().difference(transaction.timestamp!).inMinutes;
          if (timeDifference > 30) {
            throw Exception(
                'La transaction ne peut plus être annulée après 30 minutes');
          }
        }

        // Vérifier le type de transaction
        if (transaction.type != TransactionType.transfer) {
          throw Exception('Seuls les transferts peuvent être annulés');
        }

        // Vérifier le statut actuel
        if (transaction.status.toLowerCase() == 'cancelled') {
          throw Exception('Cette transaction a déjà été annulée');
        }

        // Rembourser les montants
        if (transaction.senderId != null && transaction.receiverId != null) {
          // Calculer le montant total à rembourser (incluant les frais si l'expéditeur les a payés)
          double amountToRefund = transaction.userPaidFee
              ? transaction.amount + transaction.feeAmount
              : transaction.amount;

          // Rembourser l'expéditeur
          TransactionFirebase.update(
              _firestore.collection('users').doc(transaction.senderId),
              {'balance': FieldValue.increment(amountToRefund)});

          // Débiter le destinataire
          TransactionFirebase.update(
              _firestore.collection('users').doc(transaction.receiverId),
              {'balance': FieldValue.increment(-transaction.amount)});
        }

        // Mettre à jour le statut de la transaction
        TransactionFirebase.update(
            _firestore.collection('transactions').doc(transactionId), {
          'status': 'cancelled',
          'metadata': {
            ...transaction.metadata,
            'cancelledAt': DateTime.now().toIso8601String(),
            'originalStatus': transaction.status
          }
        });
      });
    } catch (e) {
      print('Erreur lors de l\'annulation de la transaction : $e');
      throw Exception('L\'annulation de la transaction a échoué : $e');
    }
  }

  // Méthode utilitaire pour convertir TransactionType en String
  String _convertTransactionTypeToString(TransactionType type) {
    return type.toString().split('.').last;
  }
}
