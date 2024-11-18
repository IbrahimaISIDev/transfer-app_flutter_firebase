// import 'package:get/get.dart';
// import '../../data/models/transaction_model.dart';
// import '../../data/providers/user_provider.dart';
// import '../../data/providers/transaction_provider.dart';
// import '../../data/services/firebase_service.dart';

// class DistributorOperationController extends GetxController {
//   final UserProvider _userProvider = UserProvider();
//   final TransactionProvider _transactionProvider = TransactionProvider();
//   final FirebaseService _firebaseService = FirebaseService();

//   Future<void> makeDeposit(String phoneNumber, double amount) async {
//     try {
//       var user = await _userProvider.getUserByPhone(phoneNumber);
      
//       if (user == null) {
//         Get.snackbar('Erreur', 'Utilisateur non trouvé');
//         return;
//       }

//       TransactionModel transaction = TransactionModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         senderId: _firebaseService.getCurrentUserId(),
//         receiverId: user.id,
//         amount: amount,
//         timestamp: DateTime.now(),
//         type: TransactionType.deposit
//       );

//       await _transactionProvider.createTransaction(transaction);
//       await _userProvider.updateUserBalance(user.id, amount);

//       Get.snackbar('Succès', 'Dépôt effectué');
//     } catch (e) {
//       Get.snackbar('Erreur', 'Échec du dépôt');
//     }
//   }

//   Future<void> makeWithdrawal(String phoneNumber, double amount) async {
//     try {
//       var user = await _userProvider.getUserByPhone(phoneNumber);
      
//       if (user == null) {
//         Get.snackbar('Erreur', 'Utilisateur non trouvé');
//         return;
//       }

//       TransactionModel transaction = TransactionModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         senderId: _firebaseService.getCurrentUserId(),
//         receiverId: user.id,
//         amount: amount,
//         timestamp: DateTime.now(),
//         type: TransactionType.withdrawal
//       );

//       await _transactionProvider.createTransaction(transaction);
//       await _userProvider.updateUserBalance(user.id, -amount);

//       Get.snackbar('Succès', 'Retrait effectué');
//     } catch (e) {
//       Get.snackbar('Erreur', 'Échec du retrait');
//     }
//   }
// }

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class DistributorOperationController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  
  final phoneController = TextEditingController();
  final amountController = TextEditingController();

  Future<void> performDeposit() async {
    try {
      final phoneNumber = phoneController.text.trim();
      final amount = double.parse(amountController.text.trim());

      await _firebaseService.createDeposit(phoneNumber, amount);
      
      Get.snackbar(
        'Succès', 
        'Dépôt effectué',
        backgroundColor: Colors.green,
        colorText: Colors.white
      );

      // Réinitialiser les champs
      phoneController.clear();
      amountController.clear();
    } catch (e) {
      Get.snackbar(
        'Erreur', 
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
    }
  }

  Future<void> performWithdrawal() async {
    try {
      final phoneNumber = phoneController.text.trim();
      final amount = double.parse(amountController.text.trim());

      await _firebaseService.createWithdrawal(phoneNumber, amount);
      
      Get.snackbar(
        'Succès', 
        'Retrait effectué',
        backgroundColor: Colors.green,
        colorText: Colors.white
      );

      // Réinitialiser les champs
      phoneController.clear();
      amountController.clear();
    } catch (e) {
      Get.snackbar(
        'Erreur', 
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    super.onClose();
  }
}