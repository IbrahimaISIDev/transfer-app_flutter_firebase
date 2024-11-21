import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/data/providers/transaction_provider.dart';
import 'package:money_transfer_app/app/data/providers/user_provider.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class ClientTransactionController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final TransactionProvider _transactionProvider = TransactionProvider();
  final FirebaseService _firebaseService = FirebaseService();

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

  // Créer un transfert individuel
  Future createTransfer(String phoneNumber, double amount) async {
    try {
      // Récupérer l'utilisateur destinataire
      var receiver = await _userProvider.getUserByPhone(phoneNumber);

      if (receiver == null) {
        Get.snackbar('Erreur', 'Destinataire non trouvé');
        return;
      }

      if (receiver.id == null) {
        Get.snackbar('Erreur', 'ID du destinataire manquant');
        return;
      }

      // Vérifier que le destinataire n'est pas l'expéditeur
      String currentUserId = _firebaseService.getCurrentUserId();
      if (receiver.id == currentUserId) {
        Get.snackbar('Erreur',
            'Vous ne pouvez pas vous transférer de l\'argent à vous-même');
        return;
      }

      // Vérifier le solde suffisant
      UserModel? currentUser = await _userProvider.getUserById(currentUserId);
      if (currentUser == null || currentUser.balance < amount) {
        Get.snackbar('Erreur', 'Solde insuffisant');
        return;
      }

      // Créer la transaction
      TransactionModel transaction = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: currentUserId,
          receiverId: receiver.id!,
          amount: amount,
          timestamp: DateTime.now(),
          type: TransactionType.transfer, status: '', metadata: {});

      await _transactionProvider.createTransaction(transaction);

      // Mise à jour des soldes
      await _userProvider.updateUserBalance(currentUserId, -amount);
      await _userProvider.updateUserBalance(receiver.id!, amount);

      Get.snackbar('Succès', 'Transfert effectué');
      fetchTransactions();
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du transfert : ${e.toString()}');
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
      String phoneNumber, double amount, DateTime scheduledDate) async {
    try {
      var receiver = await _userProvider.getUserByPhone(phoneNumber);

      if (receiver == null) {
        Get.snackbar('Erreur', 'Destinataire non trouvé');
        return;
      }

      // Valider la date de transfert programmé
      if (scheduledDate.isBefore(DateTime.now())) {
        Get.snackbar(
            'Erreur', 'La date de transfert programmé doit être future');
        return;
      }

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
          type: TransactionType.transfer, status: '', metadata: {});

      await _transactionProvider.createScheduledTransaction(transaction);
      Get.snackbar('Succès', 'Transfert programmé créé');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec du transfert programmé : $e');
      print('Detailed scheduled transfer error: $e');
    }
  }
}
