import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';

class ClientHomeController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxDouble balance = 0.0.obs;
  final RxBool isBalanceVisible = true.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  
  // Modify to use Rx<UserModel>
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _fetchUserData();
  }

  Future _fetchUserData() async {
    try {
      String userId = _firebaseService.getCurrentUserId();
      currentUser.value = await _firebaseService.getUserDetails(userId);
      
      if (currentUser.value != null) {
        balance.value = currentUser.value!.balance;
        transactions.value = await _firebaseService.getUserTransactions();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future refreshData() async {
    await _fetchUserData();
  }

  List<TransactionModel> get recentTransactions {
    return transactions.length > 35
        ? transactions.sublist(0, 5) 
        : transactions;
  }

  String get userName => currentUser.value?.fullName ?? 'Client';
  String get userEmail => currentUser.value?.email ?? 'Email inconnu';
  String get userPhone => currentUser.value?.phoneNumber ?? 'Téléphone inconnu';

  void toggleBalanceVisibility() {
    isBalanceVisible.toggle();
  }
}

/* 
// ClientHomeController
import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';

class ClientHomeController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  
  final RxDouble balance = 0.0.obs;
  final RxBool isBalanceVisible = true.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  // Pagination variables
  final int pageSize = 10;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreData = true.obs;
  DateTime? lastDocumentTimestamp;

  @override
  void onInit() {
    super.onInit();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      String userId = _firebaseService.getCurrentUserId();
      currentUser.value = await _firebaseService.getUserDetails(userId);
      
      if (currentUser.value != null) {
        balance.value = currentUser.value!.balance;
        await loadMoreTransactions(initial: true);
      }
    } catch (e) {
      print('Error fetching initial data: $e');
    }
  }

  Future<void> loadMoreTransactions({bool initial = false}) async {
    if (isLoading.value || (!hasMoreData.value && !initial)) return;

    try {
      isLoading.value = true;

      if (initial) {
        transactions.clear();
        lastDocumentTimestamp = null;
        hasMoreData.value = true;
      }

      final newTransactions = await _firebaseService.getPaginatedTransactions(
        limit: pageSize,
        lastTimestamp: lastDocumentTimestamp,
      );

      if (newTransactions.isEmpty) {
        hasMoreData.value = false;
      } else {
        transactions.addAll(newTransactions);
        lastDocumentTimestamp = newTransactions.last.timestamp;
      }
    } catch (e) {
      print('Error loading more transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadMoreTransactions(initial: true);
  }

  String get userName => currentUser.value?.fullName ?? 'Client';
  String get userEmail => currentUser.value?.email ?? 'Email inconnu';
  String get userPhone => currentUser.value?.phoneNumber ?? 'Téléphone inconnu';

  void toggleBalanceVisibility() {
    isBalanceVisible.toggle();
  }
} */