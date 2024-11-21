import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/providers/transaction_provider.dart';
import 'package:money_transfer_app/app/data/providers/user_provider.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

enum InputMode { manual, scanner }

// Enum pour définir les statuts de dépôt
enum DepositStatus { pending, approved, rejected }

class DistributorOperationController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();
  final FirebaseService _firebaseService = FirebaseService();

  // Contrôleurs pour les champs de formulaire
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // Variable observable pour le mode de saisie
  final Rx<InputMode> inputMode = InputMode.manual.obs;

  // Variables observables
  final RxDouble currentMonthlyDepositTotal = 0.0.obs;
  final RxInt currentDailyDepositCount = 0.obs;

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialiser les totaux de dépôt
    _updateDepositTotals();
  }

  // Mettre à jour les totaux de dépôt mensuels et journaliers
  Future<void> _updateDepositTotals() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    // Récupérer les totaux de dépôts du mois et du jour
    List<TransactionModel> monthlyTransactions =
        await _transactionProvider.getTransactionsByType(
            type: TransactionType.deposit,
            startDate: startOfMonth,
            endDate: now,
            distributorId: _firebaseService.getCurrentUserId());

    currentMonthlyDepositTotal.value = monthlyTransactions.fold(
        0.0, (total, transaction) => total + transaction.amount);

    // Filter for daily transactions (with null-safe handling)
    List<TransactionModel> dailyTransactions = monthlyTransactions
        .where((transaction) =>
            transaction.timestamp?.isAfter(startOfDay) ?? false)
        .toList();

    currentDailyDepositCount.value = dailyTransactions.length;
    currentMonthlyDepositTotal.value = dailyTransactions.fold(
        0.0, (total, transaction) => total + transaction.amount);
  }


  void clearFields() {
    phoneController.clear();
    amountController.clear();
  }

  // Méthode pour changer le mode de saisie
  void setInputMode(InputMode mode) {
    inputMode.value = mode;
  }

  // Méthode pour traiter le résultat du scan QR
  void handleQRScanResult(String? scannedData) {
    if (scannedData != null && scannedData.isNotEmpty) {
      phoneController.text = scannedData;
      setInputMode(InputMode.manual); // Retour au mode manuel après le scan
    }
  }

  Future<void> makeWithdrawal(String phoneNumber, double amount) async {
    try {
      var user = await _userProvider.getUserByPhone(phoneNumber);

      if (user == null) {
        Get.snackbar('Erreur', 'Utilisateur non trouvé');
        return;
      }

      TransactionModel transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _firebaseService.getCurrentUserId(),
        receiverId: user.id!,
        amount: amount,
        timestamp: DateTime.now(),
        type: TransactionType.withdrawal,
        scheduledDate: null,
        status: '',
        metadata: {},
      );

      await _transactionProvider.createTransaction(transaction);
      await _userProvider.updateUserBalance(user.id!, -amount);

      Get.snackbar('Succès', 'Retrait effectué');
      clearFields(); // Nettoyer les champs après succès
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du retrait');
    }
  }

  Future<void> makeUnlimit(String phoneNumber, double amount) async {
    try {
      var user = await _userProvider.getUserByPhone(phoneNumber);

      if (user == null) {
        Get.snackbar('Erreur', 'Utilisateur non trouvé');
        return;
      }

      TransactionModel transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _firebaseService.getCurrentUserId(),
        receiverId: user.id!,
        amount: amount,
        timestamp: DateTime.now(),
        type: TransactionType.unlimit,
        status: '',
        metadata: {},
      );

      await _transactionProvider.createTransaction(transaction);
      await _userProvider.updateUserLimit(user.id!, amount);

      Get.snackbar('Succès', 'Déplafonnement effectué');
      clearFields(); // Nettoyer les champs après succès
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du déplafonnement');
    }
  }

  void performUnlimit() {
    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }
    makeUnlimit(
      phoneController.text.trim(),
      double.parse(amountController.text.trim()),
    );
  }

  
  
}
