import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/data/providers/transaction_provider.dart';
import 'package:money_transfer_app/app/data/providers/user_provider.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';
import 'package:money_transfer_app/app/modules/distributor/controllers/operation_controller.dart';

// Enum pour les statuts de déplafonnement
enum UnlimitStatus { pending, approved, rejected }

class DistributorUnlimitController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();
  final FirebaseService _firebaseService = FirebaseService();

  // Contrôleurs pour les champs de formulaire
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // Configurations des limites de déplafonnement
  static const double MIN_UNLIMIT_AMOUNT =
      10000; // Montant minimum de déplafonnement
  static const double MAX_UNLIMIT_AMOUNT =
      1000000; // Montant maximum de déplafonnement
  static const int MAX_MONTHLY_UNLIMIT_TRANSACTIONS =
      2; // Max 2 déplafonnements par mois

  // Variables observables
  final Rx<InputMode> inputMode = InputMode.manual.obs;
  final RxInt currentMonthlyUnlimitCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialiser les totaux de déplafonnement
    _updateUnlimitTotals();
  }

  // Mettre à jour les totaux de déplafonnement mensuels
  Future<void> _updateUnlimitTotals() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    // Récupérer les totaux de déplafonnements du mois
    List<TransactionModel> monthlyTransactions =
        await _transactionProvider.getTransactionsByType(
            type: TransactionType.unlimit,
            startDate: startOfMonth,
            endDate: now,
            distributorId: _firebaseService.getCurrentUserId());

    currentMonthlyUnlimitCount.value = monthlyTransactions.length;
  }

  // Vérifier les conditions de déplafonnement
  Future<bool> _validateUnlimit(String phoneNumber, double amount) async {
    // Vérifier si l'utilisateur existe
    UserModel? user = await _userProvider.getUserByPhone(phoneNumber);
    if (user == null) {
      Get.snackbar('Erreur', 'Utilisateur non trouvé');
      return false;
    }

    // Vérifier les limites de déplafonnement mensuel
    if (currentMonthlyUnlimitCount.value >= MAX_MONTHLY_UNLIMIT_TRANSACTIONS) {
      Get.snackbar('Erreur', 'Limite de déplafonnements mensuels atteinte');
      return false;
    }

    // Vérifier le montant de déplafonnement
    if (amount < MIN_UNLIMIT_AMOUNT || amount > MAX_UNLIMIT_AMOUNT) {
      Get.snackbar('Erreur', 'Montant de déplafonnement invalide');
      return false;
    }

    // Vérifier les conditions spécifiques du compte utilisateur
    if (!user.canUnlimit) {
      Get.snackbar('Erreur', 'Déplafonnement non autorisé pour ce compte');
      return false;
    }

    return true;
  }

  // Effectuer un déplafonnement
  Future<void> makeUnlimit() async {
    String phoneNumber = phoneController.text.trim();
    double amount = double.parse(amountController.text.trim());

    // Validation des conditions
    bool isValidUnlimit = await _validateUnlimit(phoneNumber, amount);

    if (!isValidUnlimit) return;

    try {
      // Récupérer l'utilisateur
      UserModel user = (await _userProvider.getUserByPhone(phoneNumber))!;

      // Créer la transaction de déplafonnement
      TransactionModel transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _firebaseService.getCurrentUserId(),
        receiverId: user.id!,
        amount: amount,
        timestamp: DateTime.now(),
        type: TransactionType.unlimit,
        status: UnlimitStatus.pending.toString(),
        metadata: {
          'phoneNumber': phoneNumber,
          'distributorId': _firebaseService.getCurrentUserId(),
          'previousLimit':
              user.monthlyTransactionLimit.toString(), // Conversion en String
          'newLimit': (user.monthlyTransactionLimit + amount)
              .toString() // Conversion en String
        },
      );

      // Enregistrer la transaction
      await _transactionProvider.createTransaction(transaction);

      // Mise à jour du plafond de l'utilisateur
      await _userProvider.updateUserMonthlyLimit(
          user.id!, user.monthlyTransactionLimit + amount);

      // Mise à jour des totaux de déplafonnement
      await _updateUnlimitTotals();

      // Notification de succès
      Get.snackbar('Succès',
          'Déplafonnement de $amount F CFA effectué. Nouveau plafond : ${(user.monthlyTransactionLimit + amount).toStringAsFixed(2)}');

      // Réinitialiser les champs
      clearFields();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du déplafonnement : ${e.toString()}');
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
}
