import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/favorite_model.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/data/providers/favorites_provider.dart';
import 'package:money_transfer_app/app/data/providers/transaction_provider.dart';
import 'package:money_transfer_app/app/data/providers/user_provider.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/widgets/frequency_selector.dart';


class ClientTransactionController extends GetxController {
  // Providers et Services
  final UserProvider _userProvider = UserProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();
  final FirebaseService _firebaseService = FirebaseService();
  final FavoritesProvider _favoritesProvider = FavoritesProvider();

  // Variables observables
  RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      String currentUserId = _firebaseService.getCurrentUserId();
      transactions.value =
          await _transactionProvider.getUserTransactions(currentUserId);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les transactions');
    }
  }

  // New method to preview transfer amounts
  // Map<String, double> previewTransferAmounts(double amount,
  //     {bool userPaidFee = false}) {
  //   return _transactionProvider.calculateTransferAmounts(amount,
  //       userPaidFee: userPaidFee);
  // }

  Map<String, double> previewTransferAmounts(double amount,
      {required bool userPaidFee}) {
    const double feePercentage = 0.02; // Exemple de frais de 2%
    double feeAmount = amount * feePercentage;

    if (userPaidFee) {
      return {
        'totalAmount': amount + feeAmount,
        'receivableAmount': amount,
        'feeAmount': feeAmount,
      };
    } else {
      return {
        'totalAmount': amount,
        'receivableAmount': amount - feeAmount,
        'feeAmount': feeAmount,
      };
    }
  }

  Future<void> fetchTransactionsByType(TransactionType type) async {
    try {
      String currentUserId = _firebaseService.getCurrentUserId();
      transactions.value = await _transactionProvider.getUserTransactionsByType(
          currentUserId, type);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les transactions filtrées');
    }
  }

  // Voici la nouvelle méthode createTransfer
  Future<void> createTransfer(String phoneNumber, double amount,
      {bool userPaidFee = false}) async {
    try {
      // Calculate transfer amounts
      var transferDetails =
          previewTransferAmounts(amount, userPaidFee: userPaidFee);

      // Use the appropriate total amount for balance check
      double totalAmountToDeduct = transferDetails['totalAmount']!;

      // 1. Validation des entrées
      if (phoneNumber.isEmpty) {
        Get.snackbar('Erreur', 'Le numéro de téléphone est requis');
        return;
      }

      if (amount <= 0) {
        Get.snackbar('Erreur', 'Le montant doit être supérieur à 0');
        return;
      }

      // 2. Récupérer l'ID de l'utilisateur courant
      String currentUserId = _firebaseService.getCurrentUserId();

      // 3. Récupérer les détails de l'expéditeur (utilisateur courant)
      UserModel? currentUser = await _userProvider.getUserById(currentUserId);
      if (currentUser == null) {
        Get.snackbar('Erreur', 'Impossible de récupérer vos informations');
        return;
      }

      // 4. Vérifier si l'utilisateur a dépassé sa limite mensuelle
      // if (amount > currentUser.monthlyTransactionLimit) {
      //   Get.snackbar('Erreur',
      //       'Ce montant dépasse votre limite mensuelle de transactions');
      //   return;
      // }

      // 5. Récupérer le destinataire par numéro de téléphone
      var receiver = await _userProvider.getUserByPhone(phoneNumber);
      if (receiver == null) {
        Get.snackbar('Erreur', 'Destinataire non trouvé');
        return;
      }

      if (receiver.id == null) {
        Get.snackbar('Erreur', 'ID du destinataire manquant');
        return;
      }

      // 6. Vérifier que le destinataire n'est pas l'expéditeur
      if (receiver.id == currentUserId) {
        Get.snackbar('Erreur',
            'Vous ne pouvez pas vous transférer de l\'argent à vous-même');
        return;
      }

      // 7. Vérifier le solde suffisant
      if (currentUser.balance < totalAmountToDeduct) {
        Get.snackbar('Erreur', 'Solde insuffisant');
        return;
      }

      // 8. Créer la transaction
      final String transactionId =
          DateTime.now().millisecondsSinceEpoch.toString();
      final TransactionModel transaction = TransactionModel(
        id: transactionId,
        senderId: currentUserId,
        receiverId: receiver.id!,
        amount: amount,
        type: TransactionType.transfer,
        status: 'completed',
        metadata: {
          'senderName': currentUser.fullName,
          'receiverName': receiver.fullName,
          'receiverPhone': receiver.phoneNumber,
        },
        timestamp: DateTime.now(),
        description: 'Transfert à ${receiver.fullName ?? receiver.phoneNumber}',
        feeAmount: transferDetails['feeAmount']!,
        userPaidFee: userPaidFee,
        feePercentage: TransactionProvider.BASE_FEE_PERCENTAGE,
      );

      // 9. Démarrer une transaction Firestore
      await FirebaseFirestore.instance
          .runTransaction((TransactionFirebase) async {
        // Vérifier à nouveau le solde (pour éviter les conditions de course)
        DocumentSnapshot senderDoc = await TransactionFirebase.get(
            FirebaseFirestore.instance.collection('users').doc(currentUserId));

        double currentBalance =
            (senderDoc.data() as Map<String, dynamic>)['balance'] ?? 0.0;
        if (currentBalance < amount) {
          throw Exception('Solde insuffisant');
        }

        // Mettre à jour le solde de l'expéditeur
        TransactionFirebase.update(
            FirebaseFirestore.instance.collection('users').doc(currentUserId),
            {'balance': FieldValue.increment(-amount)});

        // Mettre à jour le solde du destinataire
        TransactionFirebase.update(
            FirebaseFirestore.instance.collection('users').doc(receiver.id),
            {'balance': FieldValue.increment(amount)});

        // Créer l'enregistrement de la transaction
        TransactionFirebase.set(
            FirebaseFirestore.instance
                .collection('transactions')
                .doc(transactionId),
            transaction
                .toJson() // Utilisation correcte de la méthode toJson() sur l'objet TransactionModel
            );
      });

      // 10. Ajouter aux favoris si pas déjà présent
      try {
        bool isAlreadyFavorite =
            await _favoritesProvider.isFavorite(currentUserId, phoneNumber);

        if (!isAlreadyFavorite) {
          FavoriteModel favorite = FavoriteModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: currentUserId,
            recipientPhone: phoneNumber,
            recipientFullName: receiver.fullName,
            createdAt: DateTime.now(),
          );

          await _favoritesProvider.addToFavorites(favorite);
        }
      } catch (e) {
        // On ne bloque pas le processus si l'ajout aux favoris échoue
        print('Erreur lors de l\'ajout aux favoris: $e');
      }

      // 11. Rafraîchir les transactions et notifier le succès
      await fetchTransactions();
      Get.snackbar(
        'Succès',
        'Transfert de ${amount.toStringAsFixed(2)} effectué vers ${receiver.fullName ?? phoneNumber}',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      // 12. Gestion des erreurs
      print('Erreur détaillée du transfert: $e');
      Get.snackbar(
        'Erreur',
        'Échec du transfert : ${e.toString()}',
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  // Créer plusieurs transferts en parallèle
  Future<void> createMultipleTransfers(
      List<Map<String, dynamic>> transfers) async {
    try {
      await Future.wait(transfers.map((transfer) async {
        try {
          String phoneNumber = transfer['phoneNumber']
              .text; // Accéder au texte du TextEditingController
          double amount = double.tryParse(transfer['amount'].text) ??
              0; // Convertir la valeur du montant en double
          await createTransfer(phoneNumber, amount);
        } catch (transferError) {
          print(
              'Erreur de transfert pour ${transfer['phoneNumber']}: $transferError');
        }
      }));

      Get.snackbar('Succès', 'Transferts multiples effectués');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec des transferts multiples : $e');
    }
  }

  Future<void> createScheduledTransfer(
      String phoneNumber, double amount, DateTime scheduledDate, {required TransferFrequency frequency}) async {
    try {
      var receiver = await _userProvider.getUserByPhone(phoneNumber);

      if (receiver == null) {
        Get.snackbar('Erreur', 'Destinataire non trouvé');
        return;
      }

      // // Valider la date de transfert programmé
      // if (scheduledDate.isBefore(DateTime.now())) {
      //   Get.snackbar(
      //       'Erreur', 'La date de transfert programmé doit être future');
      //   return;
      // }

      // Vérifier le solde de l'expéditeur pour un transfert programmé
      String currentUserId = _firebaseService.getCurrentUserId();
      UserModel? currentUser = await _userProvider.getUserById(currentUserId);

      if (currentUser == null || currentUser.balance < amount) {
        Get.snackbar('Erreur', 'Solde insuffisant pour le transfert programmé');
        return;
      }

      TransactionModel transaction = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: currentUserId,
          receiverId: receiver.id!,
          amount: amount,
          timestamp: DateTime.now(),
          scheduledDate: scheduledDate,
          type: TransactionType.transfer,
          status: 'pending',
          feeAmount: 0.0,
          userPaidFee: false,
          feePercentage: 0.0,
          description: 'Transfert programmé à ${receiver.fullName?? receiver.phoneNumber}',
          metadata: {});

      await _transactionProvider.createScheduledTransaction(transaction);
      Get.snackbar('Succès', 'Transfert programmé créé');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du transfert programmé : $e');
      print('Detailed scheduled transfer error: $e');
    }
  }

  Future<void> cancelTransaction(TransactionModel transaction) async {
    try {
      await _firebaseService.cancelTransaction(transaction);

      // Optional: Refresh transactions after cancellation
      await fetchTransactions();

      Get.snackbar('Succès', 'Transaction annulée');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'annuler la transaction : $e');
    }
  }

  Future<void> _addToFavoritesIfNeeded(
      String recipientPhone, UserModel recipient) async {
    try {
      String currentUserId = _firebaseService.getCurrentUserId();

      // Vérifier si déjà en favoris
      bool isAlreadyFavorite =
          await _favoritesProvider.isFavorite(currentUserId, recipientPhone);

      if (!isAlreadyFavorite) {
        // Créer un nouveau favori
        FavoriteModel favorite = FavoriteModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: currentUserId,
          recipientPhone: recipientPhone,
          recipientFullName: recipient.fullName,
          createdAt: DateTime.now(),
        );

        await _favoritesProvider.addToFavorites(favorite);
      }
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  Object getCurrentUserId() {
    return _firebaseService.getCurrentUserId();
  }
}
