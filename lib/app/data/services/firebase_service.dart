import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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

  // Future<UserCredential> login(String email, String password) async {
  //   return await _auth.signInWithEmailAndPassword(
  //     email: email,
  //     password: password
  //   );
  // }

  // Connexion
  Future<void> login(String email, String password, dynamic isLoading) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar(
          'Erreur de connexion', e.message ?? 'Une erreur est survenue');
    }
  }

  // Future<void> register(UserModel user, String password) async {
  //   UserCredential credential = await _auth.createUserWithEmailAndPassword(
  //     email: user.email,
  //     password: password
  //   );

  //   await _firestore.collection('users').doc(credential.user!.uid).set(
  //     user.toJson()
  //   );
  // }

  Future<UserModel> getUserDetails(String uid) async {
    var doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromJson(doc.data()!);
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

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
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

  // Inscription pour Client
  Future<void> registerClient(
      {required String email,
      required String password,
      required String phoneNumber,
      required String fullName,
      required dynamic isLoading}) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Création du document utilisateur dans Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'userType': 'client',
        'balance': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar(
          'Erreur d\'inscription', e.message ?? 'Une erreur est survenue');
    }
  }

  // Inscription pour Distributeur
  Future<void> registerDistributor(
      {required String email,
      required String password,
      required String phoneNumber,
      required String agentCode,
      required dynamic isLoading}) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Création du document utilisateur dans Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'phoneNumber': phoneNumber,
        'agentCode': agentCode,
        'userType': 'distributor',
        'balance': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar(
          'Erreur d\'inscription', e.message ?? 'Une erreur est survenue');
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
          'Réinitialisation', 'Un email de réinitialisation a été envoyé');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erreur', e.message ?? 'Une erreur est survenue');
    }
  }
}
