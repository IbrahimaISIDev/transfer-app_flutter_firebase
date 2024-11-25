import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/providers/transaction_provider.dart';
import 'package:money_transfer_app/app/data/providers/user_provider.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

enum InputMode { manual, scanner }

enum DepositStatus { pending, approved, rejected }

enum OperationType { deposit, withdrawal, unlimit }

class DistributorOperationController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();
  final FirebaseService _firebaseService = FirebaseService();

  // Form controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // Observable variables
  final Rx<InputMode> inputMode = InputMode.manual.obs;
  final RxDouble currentMonthlyDepositTotal = 0.0.obs;
  final RxInt currentDailyDepositCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _updateDepositTotals();
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    super.onClose();
  }

  Future<void> _updateDepositTotals() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      List<TransactionModel> monthlyTransactions =
          await _transactionProvider.getTransactionsByType(
              type: TransactionType.deposit,
              startDate: startOfMonth,
              endDate: now,
              distributorId: _firebaseService.getCurrentUserId());

      _updateTotals(monthlyTransactions, startOfDay);
    } catch (e) {
      errorMessage.value = 'Erreur lors de la mise à jour des totaux';
    }
  }

  void _updateTotals(List<TransactionModel> transactions, DateTime startOfDay) {
    currentMonthlyDepositTotal.value = transactions.fold(
        0.0, (total, transaction) => total + transaction.amount);

    List<TransactionModel> dailyTransactions = transactions
        .where((transaction) =>
            transaction.timestamp?.isAfter(startOfDay) ?? false)
        .toList();

    currentDailyDepositCount.value = dailyTransactions.length;
  }

  void clearFields() {
    phoneController.clear();
    amountController.clear();
    errorMessage.value = '';
  }

  void setInputMode(InputMode mode) => inputMode.value = mode;

  void handleQRScanResult(String? scannedData) {
    if (scannedData != null && scannedData.isNotEmpty) {
      phoneController.text = scannedData;
      setInputMode(InputMode.manual);
    }
  }

  Future<void> performOperation(OperationType type) async {
    if (!_validateInputs()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final phoneNumber = phoneController.text.trim();
      final amount = double.parse(amountController.text.trim());

      switch (type) {
        case OperationType.withdrawal:
          await makeWithdrawal(phoneNumber, amount);
          break;
        case OperationType.unlimit:
          await makeUnlimit(phoneNumber, amount);
          break;
        default:
          throw Exception('Operation type not supported');
      }

      clearFields();
      await _updateDepositTotals();
    } catch (e) {
      errorMessage.value = 'Une erreur est survenue: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInputs() {
    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      errorMessage.value = 'Veuillez remplir tous les champs';
      return false;
    }

    try {
      double.parse(amountController.text.trim());
      return true;
    } catch (e) {
      errorMessage.value = 'Montant invalide';
      return false;
    }
  }

  Future<void> makeWithdrawal(String phoneNumber, double amount) async {
    final user = await _userProvider.getUserByPhone(phoneNumber);
    if (user == null) throw Exception('Utilisateur non trouvé');

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _firebaseService.getCurrentUserId(),
      receiverId: user.id!,
      amount: amount,
      timestamp: DateTime.now(),
      type: TransactionType.withdrawal,
      status: 'completed',
      metadata: {'phoneNumber': phoneNumber},
      feeAmount: 0.0,
      userPaidFee: false,
      feePercentage: 0.0,
    );

    await _transactionProvider.createTransaction(transaction);
    await _userProvider.updateUserBalance(user.id!, -amount);
    Get.snackbar('Succès', 'Retrait effectué avec succès');
  }

  Future<void> makeUnlimit(String phoneNumber, double amount) async {
    final user = await _userProvider.getUserByPhone(phoneNumber);
    if (user == null) throw Exception('Utilisateur non trouvé');

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _firebaseService.getCurrentUserId(),
      receiverId: user.id!,
      amount: amount,
      timestamp: DateTime.now(),
      type: TransactionType.unlimit,
      status: 'completed',
      metadata: {'phoneNumber': phoneNumber},
      feeAmount: 0.0,
      userPaidFee: false,
      feePercentage: 0.0,
    );

    await _transactionProvider.createTransaction(transaction);
    await _userProvider.updateUserLimit(user.id!, amount);
    Get.snackbar('Succès', 'Déplafonnement effectué avec succès');
  }
}
