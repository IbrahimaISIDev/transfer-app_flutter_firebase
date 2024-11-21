import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      String cleanPhone = _cleanPhoneNumber(phoneNumber);
      List<String> phoneFormats = [
        cleanPhone,
        '+$cleanPhone',
        '00$cleanPhone',
        cleanPhone.replaceFirst(RegExp(r'^(\+|00)'), '')
      ];

      for (String format in phoneFormats) {
        var querySnapshot = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: format)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Récupérez le document et incluez l'ID
          var doc = querySnapshot.docs.first;
          var userData = doc.data();
          userData['id'] = doc.id; // Ajoutez explicitement l'ID du document
          return UserModel.fromJson(userData);
        }
      }

      return null;
    } catch (e) {
      print('Erreur de récupération utilisateur : $e');
      return null;
    }
  }

// Improved cleaning method
  String _cleanPhoneNumber(String phoneNumber) {
    // Remove spaces, dashes, parentheses, and keep leading + or 00
    return phoneNumber.replaceAll(RegExp(r'[\s\-()]'), '');
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      var doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        var userData = doc.data()!;
        userData['id'] = doc.id;
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Erreur de récupération utilisateur par ID : $e');
      return null;
    }
  }

  Future updateUserBalance(String userId, double amount) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'balance': FieldValue.increment(amount)});
    } catch (e) {
      print('Erreur de mise à jour du solde : $e');
      // Consider throwing the error to propagate it
      rethrow;
    }
  }

  updateUserLimit(String s, double amount) {}
}
