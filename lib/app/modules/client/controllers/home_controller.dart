import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class ClientHomeController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  
  final RxDouble balance = 0.0.obs;
  final RxBool isBalanceVisible = true.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchBalance();
    _fetchTransactions();
  }

  Future<void> _fetchBalance() async {
    balance.value = await _firebaseService.getUserBalance();
  }

  Future<void> _fetchTransactions() async {
    transactions.value = await _firebaseService.getUserTransactions();
  }

  void toggleBalanceVisibility() {
    isBalanceVisible.toggle();
  }

  Future<void> initiateTransfer(
    String receiverPhone, 
    double amount
  ) async {
    try {
      await _firebaseService.createTransfer(receiverPhone, amount);
      _fetchBalance();
      _fetchTransactions();
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }
}