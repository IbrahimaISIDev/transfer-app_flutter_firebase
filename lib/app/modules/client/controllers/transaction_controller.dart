import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
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
      transactions.value = await _transactionProvider.getUserTransactions(currentUserId);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les transactions');
    }
  }

  Future<void> createTransfer(String phoneNumber, double amount) async {
  try {
    // Récupérer l'utilisateur destinataire
    var receiver = await _userProvider.getUserByPhone(phoneNumber);
    
    if (receiver == null || receiver.id == null) {
      Get.snackbar('Erreur', 'Destinataire non trouvé ou ID manquant');
      return;
    }

    // Créer la transaction
    TransactionModel transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _firebaseService.getCurrentUserId(),
      receiverId: receiver.id!,  // Use '!' to assert receiver.id is not null
      amount: amount,
      timestamp: DateTime.now(),
      type: TransactionType.transfer
    );

    await _transactionProvider.createTransaction(transaction);
    
    // Mise à jour des soldes
    await _userProvider.updateUserBalance(
      _firebaseService.getCurrentUserId(), 
      -amount
    );
    await _userProvider.updateUserBalance(
      receiver.id!,  // Use '!' to assert receiver.id is not null
      amount
    );

    Get.snackbar('Succès', 'Transfert effectué');
    fetchTransactions();
  } catch (e) {
    Get.snackbar('Erreur', 'Échec du transfert');
  }
}

}