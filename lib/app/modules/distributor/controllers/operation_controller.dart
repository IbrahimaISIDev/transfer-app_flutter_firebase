import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
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

  // Configurations des limites de dépôt
  static const double MAX_DAILY_DEPOSIT = 500000; // 500 000 F CFA par jour
  static const double MAX_MONTHLY_DEPOSIT = 2000000; // 2 000 000 F CFA par mois
  static const int MAX_DAILY_DEPOSIT_TRANSACTIONS = 5; // Max 5 dépôts par jour

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
        receiverId: receiver.id!, // Non-null assertion after safety check
        amount: amount,
        timestamp: DateTime.now(),
        type: TransactionType.deposit,
        status: DepositStatus.pending.toString(),
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

  void performDeposit() {
    // Validate that fields are not empty
    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }

    // Trigger the deposit process
    makeDeposit();
  }

  void performWithdrawal() {
    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }
    makeWithdrawal(
      phoneController.text.trim(),
      double.parse(amountController.text.trim()),
    );
  }
}

// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:money_transfer_app/app/data/services/firebase_service.dart';

// class DistributorOperationController extends GetxController {
//   final FirebaseService _firebaseService = FirebaseService();
  
//   final phoneController = TextEditingController();
//   final amountController = TextEditingController();

//   Future<void> performDeposit() async {
//     try {
//       final phoneNumber = phoneController.text.trim();
//       final amount = double.parse(amountController.text.trim());

//       await _firebaseService.createDeposit(phoneNumber, amount);
      
//       Get.snackbar(
//         'Succès', 
//         'Dépôt effectué',
//         backgroundColor: Colors.green,
//         colorText: Colors.white
//       );

//       // Réinitialiser les champs
//       phoneController.clear();
//       amountController.clear();
//     } catch (e) {
//       Get.snackbar(
//         'Erreur', 
//         e.toString(),
//         backgroundColor: Colors.red,
//         colorText: Colors.white
//       );
//     }
//   }

//   Future<void> performWithdrawal() async {
//     try {
//       final phoneNumber = phoneController.text.trim();
//       final amount = double.parse(amountController.text.trim());

//       await _firebaseService.createWithdrawal(phoneNumber, amount);
      
//       Get.snackbar(
//         'Succès', 
//         'Retrait effectué',
//         backgroundColor: Colors.green,
//         colorText: Colors.white
//       );

//       // Réinitialiser les champs
//       phoneController.clear();
//       amountController.clear();
//     } catch (e) {
//       Get.snackbar(
//         'Erreur', 
//         e.toString(),
//         backgroundColor: Colors.red,
//         colorText: Colors.white
//       );
//     }
//   }

//   @override
//   void onClose() {
//     phoneController.dispose();
//     amountController.dispose();
//     super.onClose();
//   }
// }