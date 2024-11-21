import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      print('Erreur de création de transaction : $e');
    }
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    try {
      var querySnapshot = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur de récupération des transactions : $e');
      return [];
    }
  }

  Future createScheduledTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('scheduled_transactions')
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      print('Erreur de création de transaction programmée : $e');
    }
  }

  // Méthode pour exécuter les transferts programmés
  Future processScheduledTransactions() async {
    var now = DateTime.now();
    var scheduledTransactions = await _firestore
        .collection('scheduled_transactions')
        .where('scheduledDate', isLessThanOrEqualTo: now)
        .get();

    for (var doc in scheduledTransactions.docs) {
      var transaction = TransactionModel.fromJson(doc.data());
      // Logique d'exécution du transfert
    }
  }

  Future<List<TransactionModel>> getTransactionsByType({
    required TransactionType type,
    required DateTime startDate,
    required DateTime endDate,
    required String distributorId,
  }) async {
    try {
      var querySnapshot = await _firestore
          .collection('transactions')
          .where('type', isEqualTo: type.toString())
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .where('metadata.distributorId', isEqualTo: distributorId)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des transactions par type : $e');
      return [];
    }
  }
}
