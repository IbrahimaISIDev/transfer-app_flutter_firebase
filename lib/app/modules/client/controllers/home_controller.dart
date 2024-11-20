import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class ClientHomeController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxDouble balance = 0.0.obs;
  final RxBool isBalanceVisible = true.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  
  // Add current user property
  final Rx<dynamic> currentUser = Rx<dynamic>(null);

  @override
  void onInit() {
    super.onInit();
    _fetchBalance();
    _fetchTransactions();
    _fetchCurrentUser();
  }

  Future _fetchBalance() async {
    balance.value = await _firebaseService.getUserBalance();
  }

  Future _fetchTransactions() async {
    transactions.value = await _firebaseService.getUserTransactions();
  }

  Future _fetchCurrentUser() async {
    currentUser.value = _firebaseService.getCurrentUserId();
  }

  // New method to refresh all data
  Future refreshData() async {
    await Future.wait([
      _fetchBalance(),
      _fetchTransactions(),
      _fetchCurrentUser()
    ]);
  }

  // Getter for recent transactions (last 5)
  List<TransactionModel> get recentTransactions {
    // ignore: invalid_use_of_protected_member
    return transactions.value.length > 5 
      // ignore: invalid_use_of_protected_member
      ? transactions.value.sublist(0, 5) 
      // ignore: invalid_use_of_protected_member
      : transactions.value;
  }

  void toggleBalanceVisibility() {
    isBalanceVisible.toggle();
  }

  Future initiateTransfer(
    String receiverPhone,
    double amount
  ) async {
    try {
      await _firebaseService.createTransfer(receiverPhone, amount);
      await refreshData(); // Use the new refresh method
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}