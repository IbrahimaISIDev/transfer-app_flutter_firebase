import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class AuthController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  UserModel? get user => _user.value;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _firebaseService.login(email, password, isLoading);
      _user.value = await _firebaseService.getUserDetails(
          _firebaseService.getCurrentUserId());

      isLoading.value = false;

      Get.offNamed(_user.value!.userType == 'client'
          ? '/client/home'
          : '/distributor/home');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> registerClient(UserModel userData, String password) async {
    try {
      await _firebaseService.registerClient(
        email: userData.email,
        password: password,
        phoneNumber: userData.phoneNumber,
        fullName: userData.fullName,
        isLoading: isLoading,
      );
      Get.offNamed('/login');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> registerDistributor(String email, String password,
      String phoneNumber, String agentCode) async {
    try {
      await _firebaseService.registerDistributor(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        agentCode: agentCode,
        isLoading: isLoading,
      );
      Get.offNamed('/login');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> logout() async {
    await _firebaseService.logout();
    Get.offAllNamed('/login');
  }
}
