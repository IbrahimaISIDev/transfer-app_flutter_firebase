import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class AuthController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  
  UserModel? get user => _user.value;

  Future<void> login(String email, String password) async {
    try {
      UserCredential credential = await _firebaseService.login(email, password);
      _user.value = await _firebaseService.getUserDetails(credential.user!.uid);
      Get.offNamed(_user.value!.userType == UserType.client 
        ? '/client/home' 
        : '/distributor/home');
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> register(UserModel userData, String password) async {
    try {
      await _firebaseService.register(userData, password);
      Get.offNamed('/login');
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> logout() async {
    await _firebaseService.logout();
    Get.offAllNamed('/login');
  }
}