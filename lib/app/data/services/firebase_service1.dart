import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import '../models/transaction_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String getCurrentUserId() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }
    return currentUser.uid;
  }

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
  // Mise à jour de la méthode logout pour inclure Google
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); // Déconnexion de Google
      await _firestore.clearPersistence();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
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
