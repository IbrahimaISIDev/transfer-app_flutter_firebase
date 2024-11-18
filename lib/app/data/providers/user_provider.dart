import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      var querySnapshot = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Erreur de récupération utilisateur : $e');
      return null;
    }
  }

  Future<void> updateUserBalance(String userId, double amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'balance': FieldValue.increment(amount)
      });
    } catch (e) {
      print('Erreur de mise à jour du solde : $e');
    }
  }
}