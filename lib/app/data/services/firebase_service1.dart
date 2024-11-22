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

  // Connexion
  Future<void> login(String email, String password, dynamic isLoading) async {
    try {
      isLoading.value = true;

      // 1. Connexion avec Firebase Auth
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Vérifier si l'utilisateur existe dans Firestore
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('Utilisateur non trouvé');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Si l'utilisateur n'existe pas dans Firestore, on le déconnecte
        await _auth.signOut();
        throw Exception('Compte utilisateur incomplet');
      }

      print('Connexion réussie');
      Get.snackbar(
        'Succès',
        'Connexion réussie',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Erreur de connexion: $e');
      String errorMessage = 'Une erreur est survenue lors de la connexion';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Aucun utilisateur trouvé avec cet email';
            break;
          case 'wrong-password':
            errorMessage = 'Mot de passe incorrect';
            break;
          case 'invalid-email':
            errorMessage = 'Email invalide';
            break;
          case 'user-disabled':
            errorMessage = 'Ce compte a été désactivé';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      }

      Get.snackbar(
        'Erreur',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Ajoute cette méthode pour l'authentification Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Déconnexion préalable pour forcer l'affichage du sélecteur
      await _googleSignIn.signOut();

      // Déclencher le flux d'authentification Google avec le sélecteur de compte
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Sélection du compte Google annulée');
      }

      // Obtenir les détails d'authentification de la requête
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer un nouvel identifiant
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connecter l'utilisateur à Firebase avec les identifiants Google
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Vérifier si c'est un nouvel utilisateur
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Créer un nouveau document utilisateur dans Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'fullName': userCredential.user!.displayName,
          'phoneNumber': userCredential.user!.phoneNumber ?? '',
          'userType': 'client',
          'balance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // Mettre à jour la dernière connexion
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      Get.snackbar(
        'Succès',
        'Connexion réussie avec Google',
        snackPosition: SnackPosition.BOTTOM,
      );

      return userCredential;
    } catch (e) {
      print('Erreur de connexion Google: $e');
      String errorMessage = 'Erreur lors de la connexion avec Google';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage = 'Un compte existe déjà avec cet email';
            break;
          case 'invalid-credential':
            errorMessage = 'Identifiants invalides';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
      }

      Get.snackbar(
        'Erreur',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
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

  Future<bool> canCancelTransaction(TransactionModel transaction) async {
    // Check if transaction is within 30 minutes
    final now = DateTime.now();
    final transactionTime = transaction.timestamp;

    if (transactionTime == null) {
      return false;
    }

    final timeDifference = now.difference(transactionTime);
    if (timeDifference.inMinutes > 30) {
      return false;
    }

    // Check if receiver balance contains the transaction amount
    try {
      DocumentSnapshot receiverDoc = await _firestore
          .collection('users')
          .doc(transaction.receiverId)
          .get();

      double receiverBalance =
          (receiverDoc.data() as Map<String, dynamic>)['balance'] ?? 0.0;

      // Verify receiver has sufficient balance to reverse
      if (receiverBalance < transaction.amount) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking transaction cancellation: $e');
      return false;
    }
  }

  Future<void> cancelTransaction(TransactionModel transaction) async {
    try {
      // Verify cancellation is possible
      bool canCancel = await canCancelTransaction(transaction);
      if (!canCancel) {
        throw Exception('Transaction cannot be cancelled');
      }

      WriteBatch batch = _firestore.batch();

      // Reverse balance transfers
      batch.update(_firestore.collection('users').doc(transaction.senderId!),
          {'balance': FieldValue.increment(transaction.amount)});

      batch.update(_firestore.collection('users').doc(transaction.receiverId!),
          {'balance': FieldValue.increment(-transaction.amount)});

      // Mark transaction as cancelled
      DocumentReference transactionRef =
          _firestore.collection('transactions').doc(transaction.id);

      batch.update(transactionRef, {
        'status': 'cancelled',
        'cancellationTimestamp': FieldValue.serverTimestamp()
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Transaction cancellation failed: $e');
    }
  }
}
