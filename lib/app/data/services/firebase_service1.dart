import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import '../models/transaction_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getCurrentUserId() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }
    return currentUser.uid;
  }

  // Connexion
  Future<UserModel?> getUserDetails(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserBalance(String userId, double amount) async {
    await _firestore.collection('users').doc(userId).update({
      'balance': FieldValue.increment(amount),
    });
  }

  Future<double> getUserBalance() async {
    var currentUser = _auth.currentUser;
    var doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data()?['balance'] ?? 0.0;
  }

  Future<List<TransactionModel>> getUserTransactions() async {
    var currentUser = _auth.currentUser;
    var querySnapshot = await _firestore
        .collection('transactions')
        .where('senderId', isEqualTo: currentUser!.uid)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()))
        .toList();
  }

  // Méthode pour créer un dépôt
  Future<void> createDeposit(String userPhone, double amount) async {
    try {
      // Trouver l'utilisateur par numéro de téléphone
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: userPhone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('Utilisateur non trouvé');
      }

      String userId = userQuery.docs.first.id;

      // Mettre à jour le solde
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'balance': FieldValue.increment(amount)});

      // Enregistrer la transaction
      await _firestore.collection('transactions').add({
        'senderId': getCurrentUserId(), // L'ID du distributeur
        'receiverId': userId,
        'amount': amount,
        'type': 'deposit',
        'timestamp': FieldValue.serverTimestamp(),
        'description': 'Dépôt en espèces'
      });
    } catch (e) {
      throw Exception('Échec du dépôt : ${e.toString()}');
    }
  }

  // Méthode pour créer un retrait
  Future<void> createWithdrawal(String userPhone, double amount) async {
    try {
      // Trouver l'utilisateur par numéro de téléphone
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: userPhone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('Utilisateur non trouvé');
      }

      String userId = userQuery.docs.first.id;
      DocumentSnapshot userDoc = userQuery.docs.first;

      // Vérifier le solde suffisant
      double currentBalance =
          (userDoc.data() as Map<String, dynamic>)['balance'] ?? 0.0;
      if (currentBalance < amount) {
        throw Exception('Solde insuffisant');
      }

      // Mettre à jour le solde
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'balance': FieldValue.increment(-amount)});

      // Enregistrer la transaction
      await _firestore.collection('transactions').add({
        'senderId': userId,
        'receiverId': getCurrentUserId(), // L'ID du distributeur
        'amount': amount,
        'type': 'withdrawal',
        'timestamp': FieldValue.serverTimestamp(),
        'description': 'Retrait en espèces'
      });
    } catch (e) {
      throw Exception('Échec du retrait : ${e.toString()}');
    }
  }

  // Méthode pour créer un transfert
  Future<void> createTransfer(String receiverPhone, double amount) async {
    try {
      String senderId = getCurrentUserId();

      // Trouver le destinataire par numéro de téléphone
      QuerySnapshot receiverQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: receiverPhone)
          .limit(1)
          .get();

      if (receiverQuery.docs.isEmpty) {
        throw Exception('Destinataire non trouvé');
      }

      String receiverId = receiverQuery.docs.first.id;

      // Vérifier le solde de l'expéditeur
      DocumentSnapshot senderDoc =
          await _firestore.collection('users').doc(senderId).get();

      double currentBalance =
          (senderDoc.data() as Map<String, dynamic>)['balance'] ?? 0.0;
      if (currentBalance < amount) {
        throw Exception('Solde insuffisant');
      }

      // Mise à jour des soldes
      WriteBatch batch = _firestore.batch();

      // Déduire du solde de l'expéditeur
      batch.update(_firestore.collection('users').doc(senderId),
          {'balance': FieldValue.increment(-amount)});

      // Ajouter au solde du destinataire
      batch.update(_firestore.collection('users').doc(receiverId),
          {'balance': FieldValue.increment(amount)});

      // Enregistrer la transaction
      DocumentReference transactionRef =
          _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'id': transactionRef.id,
        'senderId': senderId,
        'receiverId': receiverId,
        'amount': amount,
        'type': 'transfer',
        'timestamp': FieldValue.serverTimestamp(),
        'description': 'Transfert entre utilisateurs'
      });

      // Exécuter toutes les opérations
      await batch.commit();
    } catch (e) {
      throw Exception('Échec du transfert : ${e.toString()}');
    }
  }
}
