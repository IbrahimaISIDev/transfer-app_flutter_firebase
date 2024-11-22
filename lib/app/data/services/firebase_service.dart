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

  // Déconnexion
  // Future<void> logout() async {
  //   try {
  //     // S'assurer que toutes les données locales sont effacées
  //     await _auth.signOut();
  //     // Vider le cache Firestore si nécessaire
  //     await _firestore.clearPersistence();
  //   } catch (e) {
  //     print('Erreur lors de la déconnexion: $e');
  //     rethrow;
  //   }
  // }

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

  // Méthode pour créer un dépôt
  Future<void> createDeposit(String userPhone, double amount) async {
    try {
      // 1. Trouver l'utilisateur par numéro de téléphone
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: userPhone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('Utilisateur non trouvé');
      }

      String userId = userQuery.docs.first.id;
      String distributorId = getCurrentUserId();

      // 2. Démarrer une transaction Firestore pour garantir l'atomicité
      await _firestore.runTransaction((transaction) async {
        // 2.1 Vérifier le solde du distributeur
        DocumentSnapshot distributorDoc = await transaction
            .get(_firestore.collection('users').doc(distributorId));

        if (!distributorDoc.exists) {
          throw Exception('Distributeur non trouvé');
        }

        double distributorBalance =
            (distributorDoc.data() as Map<String, dynamic>)['balance'] ?? 0.0;

        // 2.2 Vérifier si le distributeur a assez d'argent
        if (distributorBalance < amount) {
          throw Exception(
              'Solde distributeur insuffisant pour effectuer le dépôt');
        }

        // 2.3 Mettre à jour le solde du client (augmenter)
        transaction.update(_firestore.collection('users').doc(userId),
            {'balance': FieldValue.increment(amount)});

        // 2.4 Mettre à jour le solde du distributeur (diminuer)
        transaction.update(_firestore.collection('users').doc(distributorId),
            {'balance': FieldValue.increment(-amount)});

        // 2.5 Enregistrer la transaction
        DocumentReference transactionRef =
            _firestore.collection('transactions').doc();
        transaction.set(transactionRef, {
          'id': transactionRef.id,
          'senderId': distributorId,
          'receiverId': userId,
          'amount': amount,
          'type': 'deposit',
          'timestamp': FieldValue.serverTimestamp(),
          'description': 'Dépôt en espèces',
          'metadata': {
            'phoneNumber': userPhone,
            'distributorId': distributorId,
          }
        });
      });
    } catch (e) {
      throw Exception('Échec du dépôt : ${e.toString()}');
    }
  }

  Future<void> createWithdrawal(String userPhone, double amount) async {
    try {
      // 1. Trouver l'utilisateur par numéro de téléphone
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: userPhone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('Utilisateur non trouvé');
      }

      String userId = userQuery.docs.first.id;
      String distributorId = getCurrentUserId();

      // 2. Démarrer une transaction Firestore pour garantir l'atomicité
      await _firestore.runTransaction((transaction) async {
        // 2.1 Vérifier le solde du client
        DocumentSnapshot userDoc =
            await transaction.get(_firestore.collection('users').doc(userId));

        double userBalance =
            (userDoc.data() as Map<String, dynamic>)['balance'] ?? 0.0;

        // 2.2 Vérifier si le client a assez d'argent
        if (userBalance < amount) {
          throw Exception('Solde client insuffisant');
        }

        // 2.3 Mettre à jour le solde du client (diminuer)
        transaction.update(_firestore.collection('users').doc(userId),
            {'balance': FieldValue.increment(-amount)});

        // 2.4 Mettre à jour le solde du distributeur (augmenter)
        transaction.update(_firestore.collection('users').doc(distributorId),
            {'balance': FieldValue.increment(amount)});

        // 2.5 Enregistrer la transaction
        DocumentReference transactionRef =
            _firestore.collection('transactions').doc();
        transaction.set(transactionRef, {
          'id': transactionRef.id,
          'senderId': userId,
          'receiverId': distributorId,
          'amount': amount,
          'type': 'withdrawal',
          'timestamp': FieldValue.serverTimestamp(),
          'description': 'Retrait en espèces',
          'metadata': {
            'phoneNumber': userPhone,
            'distributorId': distributorId,
          }
        });
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
  Future<void> registerClient({
    required String email,
    required String password,
    required String phoneNumber,
    required String fullName,
    required RxBool isLoading,
  }) async {
    UserCredential? userCredential;
    try {
      isLoading.value = true;

      // Vérifier si l'email existe déjà
      print('Checking for existing email...');
      var emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Cet email est déjà utilisé',
        );
      }

      print('Creating user in Firebase Auth...');
      // Créer l'utilisateur dans Firebase Auth
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Échec de la création de l\'utilisateur');
      }

      print('Creating user document in Firestore...');
      // Créer le document dans Firestore avec try-catch séparé
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'phoneNumber': phoneNumber,
          'fullName': fullName,
          'userType': UserType.client.toString(), // Convertir l'enum en string
          'balance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('User document created successfully');
      } catch (firestoreError) {
        print('Error creating Firestore document: $firestoreError');
        // Si la création du document Firestore échoue, supprimer l'utilisateur Auth
        if (userCredential.user != null) {
          await userCredential.user!.delete();
        }
        throw firestoreError;
      }
    } catch (e) {
      print('Error in registerClient: $e');
      // Si l'utilisateur a été créé dans Auth mais pas dans Firestore
      if (userCredential?.user != null) {
        try {
          await userCredential!.user!.delete();
        } catch (deleteError) {
          print('Error deleting user: $deleteError');
        }
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Inscription pour Distributeur
  Future<void> registerDistributor({
    required String email,
    required String password,
    required String phoneNumber,
    required String agentCode,
    required RxBool isLoading,
  }) async {
    try {
      isLoading.value = true;

      // Vérifications préalables
      var emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Cet email est déjà utilisé',
        );
      }

      var agentQuery = await _firestore
          .collection('users')
          .where('agentCode', isEqualTo: agentCode)
          .limit(1)
          .get();

      if (agentQuery.docs.isNotEmpty) {
        throw Exception('Ce code agent est déjà utilisé');
      }

      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Échec de la création de l\'utilisateur');
      }

      // Créer le document dans Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'phoneNumber': phoneNumber,
        'agentCode': agentCode,
        'userType': 'distributor',
        'balance': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
      rethrow;
    } finally {
      isLoading.value = false;
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

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification sur Android
          await _auth.signInWithCredential(credential);
          final userId = _auth.currentUser?.uid;
          if (userId != null) {
            final userDoc =
                await _firestore.collection('users').doc(userId).get();
            if (!userDoc.exists) {
              await _auth.signOut();
              throw Exception('Compte utilisateur incomplet');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String message = 'Une erreur est survenue';
          switch (e.code) {
            case 'invalid-phone-number':
              message = 'Numéro de téléphone invalide';
              break;
            case 'too-many-requests':
              message = 'Trop de tentatives, réessayez plus tard';
              break;
          }
          onError(message);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Vérifier le code OTP
  Future<void> verifyOTP({
    required String verificationId,
    required String smsCode,
    required RxBool isLoading,
  }) async {
    try {
      isLoading.value = true;

      // Créer les credentials
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Connexion avec les credentials
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Vérifier si l'utilisateur existe dans Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('Compte utilisateur non trouvé');
      }

      print('Connexion par téléphone réussie');
      Get.snackbar(
        'Succès',
        'Connexion réussie',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Erreur de vérification OTP: $e');
      String errorMessage = 'Code de vérification incorrect';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-verification-code':
            errorMessage = 'Code de vérification invalide';
            break;
          case 'invalid-verification-id':
            errorMessage = 'Session de vérification expirée';
            break;
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
