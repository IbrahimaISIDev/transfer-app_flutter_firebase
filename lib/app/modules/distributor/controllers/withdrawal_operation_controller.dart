import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/data/providers/transaction_provider.dart';
import 'package:money_transfer_app/app/data/providers/user_provider.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/operation_controller.dart';

// Enum pour définir les statuts de retrait
enum WithdrawalStatus { pending, approved, rejected }

class DistributorWithdrawalController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();
  final FirebaseService _firebaseService = FirebaseService();

  // Contrôleurs pour les champs de formulaire
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // Configurations des limites de retrait
  static const double MIN_WITHDRAWAL_AMOUNT =
      1000; // Montant minimal de retrait
  static const double MAX_DAILY_WITHDRAWAL = 500000; // 500 000 F CFA par jour
  static const double MAX_MONTHLY_WITHDRAWAL =
      2000000; // 2 000 000 F CFA par mois
  static const int MAX_DAILY_WITHDRAWAL_TRANSACTIONS =
      5; // Max 5 retraits par jour

  // Variables observables
  final Rx<InputMode> inputMode = InputMode.manual.obs;
  final RxDouble currentMonthlyWithdrawalTotal = 0.0.obs;
  final RxInt currentDailyWithdrawalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialiser les totaux de retrait
    _updateWithdrawalTotals();
  }

  // Mettre à jour les totaux de retraits mensuels et journaliers
  Future<void> _updateWithdrawalTotals() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    // Récupérer les totaux de retraits du mois et du jour
    List<TransactionModel> monthlyTransactions =
        await _transactionProvider.getTransactionsByType(
            type: TransactionType.withdrawal,
            startDate: startOfMonth,
            endDate: now,
            distributorId: _firebaseService.getCurrentUserId());

    currentMonthlyWithdrawalTotal.value = monthlyTransactions.fold(
        0.0, (total, transaction) => total + transaction.amount);

    List<TransactionModel> dailyTransactions = monthlyTransactions
        .where((transaction) =>
            transaction.timestamp?.isAfter(startOfDay) ?? false)
        .toList();

    currentDailyWithdrawalCount.value = dailyTransactions.length;
    currentMonthlyWithdrawalTotal.value = dailyTransactions.fold(
        0.0, (total, transaction) => total + transaction.amount);
  }

  // Vérifier les conditions de retrait
  Future<bool> _validateWithdrawal(String phoneNumber, double amount) async {
    // Vérifier si l'utilisateur existe
    UserModel? user = await _userProvider.getUserByPhone(phoneNumber);
    if (user == null) {
      Get.snackbar('Erreur', 'Utilisateur non trouvé');
      return false;
    }

    // Vérifier le montant minimal de retrait
    if (amount < MIN_WITHDRAWAL_AMOUNT) {
      Get.snackbar('Erreur',
          'Montant de retrait minimal : $MIN_WITHDRAWAL_AMOUNT F CFA');
      return false;
    }

    // Vérifier le solde de l'utilisateur
    if (user.balance < amount) {
      Get.snackbar('Erreur', 'Solde insuffisant');
      return false;
    }

    // Vérifier les limites de retrait journalier
    if (currentDailyWithdrawalCount.value >=
        MAX_DAILY_WITHDRAWAL_TRANSACTIONS) {
      Get.snackbar('Erreur', 'Limite de retraits journaliers atteinte');
      return false;
    }

    // Vérifier le montant maximum de retrait journalier
    if (currentMonthlyWithdrawalTotal.value + amount > MAX_DAILY_WITHDRAWAL) {
      Get.snackbar('Erreur', 'Limite de retrait journalier dépassée');
      return false;
    }

    // Vérifier le montant maximum de retrait mensuel
    if (currentMonthlyWithdrawalTotal.value + amount > MAX_MONTHLY_WITHDRAWAL) {
      Get.snackbar('Erreur', 'Limite de retrait mensuel dépassée');
      return false;
    }

    // Vérifier les conditions spécifiques du compte utilisateur
    if (!user.canWithdraw) {
      Get.snackbar('Erreur', 'Retrait non autorisé pour ce compte');
      return false;
    }

    return true;
  }

  // Effectuer un retrait
  Future<void> makeWithdrawal() async {
    String phoneNumber = phoneController.text.trim();
    double amount = double.parse(amountController.text.trim());

    // Validation des conditions
    bool isValidWithdrawal = await _validateWithdrawal(phoneNumber, amount);

    if (!isValidWithdrawal) return;

    try {
      UserModel user = (await _userProvider.getUserByPhone(phoneNumber))!;

      // Créer la transaction de retrait
      TransactionModel transaction = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: user.id!,
          receiverId: _firebaseService.getCurrentUserId(),
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.withdrawal,
          status: WithdrawalStatus.pending.toString(),
          feeAmount: 0.0,
          userPaidFee: false,
          feePercentage: 0.0,
          metadata: {
            'phoneNumber': phoneNumber,
            'distributorId': _firebaseService.getCurrentUserId(),
          });

      // Enregistrer la transaction
      await _transactionProvider.createTransaction(transaction);

      // Mise à jour du solde de l'utilisateur
      await _userProvider.updateUserBalance(user.id!, -amount);

      // Mise à jour des totaux de retrait
      await _updateWithdrawalTotals();

      // Notification de succès
      Get.snackbar('Succès', 'Retrait de $amount F CFA effectué');

      // Réinitialiser les champs
      clearFields();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du retrait : ${e.toString()}');
    }
  }

  void clearFields() {
    phoneController.clear();
    amountController.clear();
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    super.onClose();
  }

  void performWithdrawal() {
    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }
    makeWithdrawal();
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
}
