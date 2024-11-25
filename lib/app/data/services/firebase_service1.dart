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

  Future<bool> canCancelTransaction(TransactionModel transaction) async {
    // Vérifier si la transaction date de moins de 30 minutes
    final now = DateTime.now();
    final transactionTime = transaction.timestamp;

    if (transactionTime == null) {
      return false;
    }

    final timeDifference = now.difference(transactionTime);
    if (timeDifference.inMinutes > 30) {
      return false;
    }

    // Vérifier si le destinataire a toujours les fonds
    try {
      DocumentSnapshot receiverDoc = await _firestore
          .collection('users')
          .doc(transaction.receiverId)
          .get();

      double receiverBalance =
          (receiverDoc.data() as Map<String, dynamic>)['balance'] ?? 0.0;

      // Vérifier que le destinataire a suffisamment de fonds pour l'annulation
      if (receiverBalance < transaction.amount) {
        return false;
      }

      return true;
    } catch (e) {
      print('Erreur lors de la vérification de l\'annulation: $e');
      return false;
    }
  }

  Future<void> cancelTransaction(TransactionModel transaction) async {
    try {
      // Vérifier si l'annulation est possible
      bool canCancel = await canCancelTransaction(transaction);
      if (!canCancel) {
        throw Exception('La transaction ne peut pas être annulée');
      }

      WriteBatch batch = _firestore.batch();

      // Récupérer les documents des utilisateurs pour vérification
      DocumentSnapshot senderDoc =
          await _firestore.collection('users').doc(transaction.senderId).get();
      DocumentSnapshot receiverDoc = await _firestore
          .collection('users')
          .doc(transaction.receiverId)
          .get();

      if (!senderDoc.exists || !receiverDoc.exists) {
        throw Exception('Utilisateur non trouvé');
      }

      // Effectuer le remboursement en fonction du type de transaction
      switch (transaction.type) {
        case 'deposit':
          // Pour un dépôt : retirer l'argent du compte du destinataire et le remettre au distributeur
          batch.update(
              _firestore.collection('users').doc(transaction.receiverId!),
              {'balance': FieldValue.increment(-transaction.amount)});
          break;

        case 'withdrawal':
          // Pour un retrait : remettre l'argent sur le compte du client
          batch.update(
              _firestore.collection('users').doc(transaction.senderId!),
              {'balance': FieldValue.increment(transaction.amount)});
          break;

        case 'transfer':
          // Pour un transfert : retirer du compte destinataire et remettre à l'expéditeur
          batch.update(
              _firestore.collection('users').doc(transaction.senderId!),
              {'balance': FieldValue.increment(transaction.amount)});
          batch.update(
              _firestore.collection('users').doc(transaction.receiverId!),
              {'balance': FieldValue.increment(-transaction.amount)});
          break;

        default:
          throw Exception('Type de transaction non reconnu');
      }

      // Marquer la transaction comme annulée
      DocumentReference transactionRef =
          _firestore.collection('transactions').doc(transaction.id);

      batch.update(transactionRef, {
        'status': 'cancelled',
        'cancellationTimestamp': FieldValue.serverTimestamp(),
        'cancellationReason': 'Annulation demandée par l\'utilisateur'
      });

      // Créer une nouvelle transaction d'annulation pour traçabilité
      DocumentReference newTransactionRef =
          _firestore.collection('transactions').doc();
      batch.set(newTransactionRef, {
        'originalTransactionId': transaction.id,
        'senderId': transaction.receiverId, // Inversé pour l'annulation
        'receiverId': transaction.senderId, // Inversé pour l'annulation
        'amount': transaction.amount,
        'type': 'cancellation',
        'timestamp': FieldValue.serverTimestamp(),
        'description': 'Annulation de la transaction ${transaction.id}',
        'status': 'completed'
      });

      await batch.commit();

      // Notification de succès
      Get.snackbar(
        'Succès',
        'La transaction a été annulée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
      Get.snackbar(
        'Erreur',
        'L\'annulation de la transaction a échoué: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      throw Exception('L\'annulation de la transaction a échoué: $e');
    }
  }
}
