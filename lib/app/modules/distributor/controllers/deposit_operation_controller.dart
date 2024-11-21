import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/data/providers/transaction_provider.dart';
import 'package:money_transfer_app/app/data/providers/user_provider.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/operation_controller.dart';

// Enum pour définir les statuts de dépôt
enum DepositStatus { pending, approved, rejected }

class DistributorDepositController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();
  final FirebaseService _firebaseService = FirebaseService();

  // Contrôleurs pour les champs de formulaire
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // Configurations des limites de dépôt
  static const double MAX_DAILY_DEPOSIT = 500000; // 500 000 F CFA par jour
  static const double MAX_MONTHLY_DEPOSIT = 2000000; // 2 000 000 F CFA par mois
  static const int MAX_DAILY_DEPOSIT_TRANSACTIONS = 5; // Max 5 dépôts par jour

  // Variables observables
  final Rx<InputMode> inputMode = InputMode.manual.obs;
  final RxDouble currentMonthlyDepositTotal = 0.0.obs;
  final RxInt currentDailyDepositCount = 0.obs;

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

  // Vérifier les conditions de dépôt
  Future<bool> _validateDeposit(String phoneNumber, double amount) async {
    // Vérifier si l'utilisateur existe
    UserModel? user = await _userProvider.getUserByPhone(phoneNumber);
    if (user == null) {
      Get.snackbar('Erreur', 'Utilisateur non trouvé');
      return false;
    }

    // Vérifier les limites de dépôt journalier
    if (currentDailyDepositCount.value >= MAX_DAILY_DEPOSIT_TRANSACTIONS) {
      Get.snackbar('Erreur', 'Limite de dépôts journaliers atteinte');
      return false;
    }

    // Vérifier le montant maximum de dépôt journalier
    if (currentMonthlyDepositTotal.value + amount > MAX_DAILY_DEPOSIT) {
      Get.snackbar('Erreur', 'Limite de dépôt journalier dépassée');
      return false;
    }

    // Vérifier le montant maximum de dépôt mensuel
    if (currentMonthlyDepositTotal.value + amount > MAX_MONTHLY_DEPOSIT) {
      Get.snackbar('Erreur', 'Limite de dépôt mensuel dépassée');
      return false;
    }

    // Vérifier les conditions spécifiques du compte utilisateur
    if (!user.canDeposit) {
      Get.snackbar('Erreur', 'Dépôt non autorisé pour ce compte');
      return false;
    }

    return true;
  }

  // Effectuer un dépôt
  Future<void> makeDeposit() async {
    // Get and validate input values
    String phoneNumber = phoneController.text.trim();
    String amountText = amountController.text.trim();

    if (phoneNumber.isEmpty || amountText.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }

    // Ensure the amount is a valid number
    double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Erreur', 'Veuillez entrer un montant valide');
      return;
    }

    // Validation des conditions
    bool isValidDeposit = await _validateDeposit(phoneNumber, amount);

    if (!isValidDeposit) return;

    try {
      // Retrieve receiver user details
      var receiver = await _userProvider.getUserByPhone(phoneNumber);
      if (receiver == null || receiver.id == null) {
        throw Exception(
            "Le numéro de téléphone est invalide ou l'utilisateur est introuvable.");
      }

      // Create deposit transaction
      TransactionModel transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _firebaseService.getCurrentUserId(),
        receiverId: receiver.id!,
        amount: amount,
        timestamp: DateTime.now(),
        type: TransactionType.deposit,
        status: DepositStatus.pending.toString(), // Convert to string
        metadata: {
          'phoneNumber': phoneNumber,
          'distributorId': _firebaseService.getCurrentUserId(),
        },
      );

      // Save the transaction
      await _transactionProvider.createTransaction(transaction);

      // Update balances and totals
      await _userProvider.updateUserBalance(receiver.id!, amount);
      await _updateDepositTotals();

      // Notify success
      Get.snackbar('Succès', 'Dépôt de $amount F CFA effectué');

      // Clear input fields
      clearFields();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du dépôt : ${e.toString()}');
    }
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

  void performDeposit() {
    // Validate that fields are not empty
    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }

    // Trigger the deposit process
    makeDeposit();
  }
}
