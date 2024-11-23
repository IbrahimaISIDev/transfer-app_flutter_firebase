import 'package:get/get.dart';
import 'package:money_transfer_app/app/data/services/firebase_service.dart';
import 'package:money_transfer_app/app/modules/auth/controllers/auth_controller.dart';

class GlobalBindings implements Bindings {
  @override
  void dependencies() {
    // Services
    Get.put<FirebaseService>(FirebaseService(), permanent: true); // Initialisation immédiate

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController());
  }
}