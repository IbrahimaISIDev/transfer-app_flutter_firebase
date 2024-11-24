import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/models/user_model.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';

class ProfileController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      String userId = _firebaseService.getCurrentUserId();
      UserModel? user = await _firebaseService.getUserDetails(userId);
      currentUser.value = user;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les données utilisateur');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseService.logout();
      Get.offAllNamed('/login'); // Redirection vers la page de connexion
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la déconnexion');
    }
  }
}